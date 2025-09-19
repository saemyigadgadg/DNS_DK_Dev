import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import SHEETJS from '@salesforce/resourceUrl/SheetJS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertGlobal from '@salesforce/apex/DN_OpportunityGlobalImportController.upsertAccountsByFMUpload'

// 헤더: 4행(A4), 데이터: 5행부터
const HEADERS = [
  'Distributor Id','Distributor Name','Distributor Manager Email',
  'Account Customer Code','Account Name','Account Representative',
  'Account Phone','Account Email','Account Contact Name',
  'Country','Main Category','Sub Category','Opportunity No',
  'Model Name','Estimated Contract Date','Requested Delivery Date','Competitor'
];

export default class dN_OpportunityGlobalImport extends LightningElement {
  sheetLoaded = false;

  @track rows = [];
  @track errors = [];
  @track preview = [];
  headerOrder = HEADERS;
  disableImport = true;

  // 파일 저장 관련(현 단계엔 UI만 유지)
  saveOriginal = false;
  parentRecordId = '';
  selectedFileName = '';
  selectedFileBase64 = '';
  isUploading = false;
  connectedCallback() {
    loadScript(this, SHEETJS + '/xlsx-js-style-master/dist/xlsx.bundle.js')
      .then(() => { this.sheetLoaded = true; console.log('[SheetJS] loaded'); })
      .catch(err => {
        this.sheetLoaded = false;
        this.errors = ['SheetJS 로드 실패: ' + (err?.message || err)];
      });
  }

  toggleSaveOriginal(e){ this.saveOriginal = e.target.checked; }
  handleParentId(e){ this.parentRecordId = e.target.value?.trim(); }

  resetFile() {
    const input = this.template.querySelector('[data-id="fileInput"]');
    if (input) input.value = null;
    this.rows = [];
    this.preview = [];
    this.errors = [];
    this.disableImport = true;
    this.selectedFileName = '';
    this.selectedFileBase64 = '';
  }

  handleFile(event) {
    this.resetFile();
    const file = event.target.files?.[0];
    if (!file) return;

    if (!this.sheetLoaded) {
      this.errors = ['라이브러리 로드 중입니다. 잠시 후 다시 시도하세요.'];
      return;
    }

    this.selectedFileName = file.name;

    // 1) 파싱용: ArrayBuffer
    const readerAB = new FileReader();
    readerAB.onload = (e) => {
      try {
        const data = new Uint8Array(e.target.result);
        // const wb = window.XLSX.read(data, { type: 'array' });
        const wb = window.XLSX.read(data, { type: 'array', cellDates: true });
        const sheetName = wb.SheetNames[0];
        if (!sheetName) { this.errors = ['Please Check Excel Sheet']; return; }
        const sheet = wb.Sheets[sheetName];

        // 4행을 헤더로 사용(range: 3), 빈 셀도 키 유지(defval: '')
        // const json = window.XLSX.utils.sheet_to_json(sheet, { defval: '', range: 3 });
        const json = window.XLSX.utils.sheet_to_json(sheet, {
        defval: '',
        range: 3,
        raw: false,             // 셀 서식 적용
        dateNF: 'yyyy-mm-dd'    // 날짜를 이 포맷으로 문자열화
       });
        if (!json.length) { this.errors = ['No Data']; return; }

        // 콘솔: RAW
        console.log('---[RAW rows from Excel]---');
        console.log(json);

        const headerKeys = Object.keys(json[0]);
        const missing = HEADERS.filter(h => !headerKeys.includes(h));
        const extra = headerKeys.filter(k => !HEADERS.includes(k));
        if (missing.length) { this.errors = [`헤더 불일치(부족): ${missing.join(', ')}`]; return; }
        if (extra.length)   { this.showToast('경고', `정의되지 않은 컬럼: ${extra.join(', ')}`, 'warning'); }
        this.headerOrder = HEADERS;

        // 미리보기(최대 100행): 각 행에 __key와 cells 배열을 만들어 둔다
        this.preview = json.slice(0, 100).map((r, i) => ({
        __key: `${r['Distributor Id'] || ''}-${r['Account Name'] || ''}-${r['Opportunity No'] || ''}-${i}`,
        cells: this.headerOrder.map(h => ({
            key: `${i}-${h}`,           // 셀 고유 키
            // value: (r[h] ?? '').toString()  // 화면에 찍을 값
        value: (h === 'Estimated Contract Date' || h === 'Requested Delivery Date')
                    ? this.normalizeDate(r[h])
                    : (r[h] ?? '').toString()


        }))
        }));

        // 서버 전송용 정규화(현재는 콘솔 출력만 사용)
        const normalized = json.map((r) => ({
          distributorId:            r['Distributor Id']?.toString().trim(),
          distributorName:          r['Distributor Name']?.toString().trim(),
          distributorManagerEmail:  r['Distributor Manager Email']?.toString().trim(),
          accountCustomerCode:      r['Account Customer Code']?.toString().trim(),
          accountName:              r['Account Name']?.toString().trim(),
          accountRepresentative:    r['Account Representative']?.toString().trim(),
          accountPhone:             r['Account Phone']?.toString(),
          accountEmail:             r['Account Email']?.toString().trim(),
          accountContactName:       r['Account Contact Name']?.toString().trim(),
          country:                  r['Country']?.toString().trim(),
          mainCategory:             r['Main Category']?.toString().trim(),
          subCategory:              r['Sub Category']?.toString().trim(),
          opportunityNo:            r['Opportunity No']?.toString().trim(),
          modelName:                r['Model Name']?.toString().trim(),
          estimatedContractDate:    this.normalizeDate(r['Estimated Contract Date']),
          requestedDeliveryDate:    this.normalizeDate(r['Requested Delivery Date']),
          competitor:               r['Competitor']?.toString().trim()
        }));

        // 간단 검증
        const errs = [];
        normalized.forEach((row, i) => {
          const line = i + 5; // 실제 데이터 시작 행
          if (!row.accountName) errs.push(`[${line}row] Account Name Required`);
          if (row.accountEmail && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(row.accountEmail)) {
            errs.push(`[${line}row] Account Email Format Error: ${row.accountEmail}`);
          }
          if (row.estimatedContractDate && !/^\d{4}-\d{2}-\d{2}$/.test(row.estimatedContractDate)) {
            errs.push(`[${line}row] Estimated Contract Date Format Error: ${row.estimatedContractDate}`);
          }
          if (row.requestedDeliveryDate && !/^\d{4}-\d{2}-\d{2}$/.test(row.requestedDeliveryDate)) {
            errs.push(`[${line}row] Requested Delivery Date Format Error: ${row.requestedDeliveryDate}`);
          }
        });

        this.rows = normalized;
        // 콘솔: Normalized
        console.log('---[Normalized rows]---');
        console.log(JSON.stringify(this.rows));

        this.errors = errs;
        this.disableImport = errs.length > 0 || this.rows.length === 0;
      } catch (err) {
        this.errors = ['File Pasing Error: ' + (err?.message || err)];
      }
    };
    readerAB.readAsArrayBuffer(file);

    // 2) 파일 저장용: Base64 (UI 유지용)
    const readerB64 = new FileReader();
    readerB64.onload = () => {
      const dataUrl = readerB64.result;
      const base64 = dataUrl.split(',')[1] || '';
      this.selectedFileBase64 = base64;
    };
    readerB64.readAsDataURL(file);
  }

  // normalizeDate(raw) {
  //   if (raw === null || raw === undefined) return '';
  //   if (typeof raw === 'number') {
  //     const base = new Date(Date.UTC(1899, 11, 30));
  //     const d = new Date(base.getTime() + raw * 86400000);
  //     return `${d.getUTCFullYear()}-${String(d.getUTCMonth()+1).padStart(2,'0')}-${String(d.getUTCDate()).padStart(2,'0')}`;
  //   }
  //   const s = raw.toString().trim();
  //   if (!s) return '';
  //   const m = s.match(/^(\d{4})[-\/\.](\d{1,2})[-\/\.](\d{1,2})$/);
  //   if (m) {
  //     const y = m[1], mo = m[2].padStart(2,'0'), da = m[3].padStart(2,'0');
  //     return `${y}-${mo}-${da}`;
  //   }
  //   return s;
  // }

 normalizeDate(raw) {
    if (raw === null || raw === undefined) return '';

    // 1) Date 객체 직접 처리 (cellDates:true 켜진 경우 등)
    if (raw instanceof Date && !isNaN(raw.getTime())) {
      const y = raw.getUTCFullYear();
      const m = String(raw.getUTCMonth() + 1).padStart(2, '0');
      const d = String(raw.getUTCDate()).padStart(2, '0');
      return `${y}-${m}-${d}`;
    }

    // 2) 숫자 or 숫자문자열(엑셀 시리얼값) 처리
    const num = (typeof raw === 'number') ? raw : Number(String(raw).trim());
    if (!isNaN(num) && num > 20000 && num < 60000) { // 합리적 엑셀 시리얼 범위
      const base = new Date(Date.UTC(1899, 11, 30));
      const dt = new Date(base.getTime() + num * 86400000);
      const y = dt.getUTCFullYear();
      const m = String(dt.getUTCMonth() + 1).padStart(2, '0');
      const d = String(dt.getUTCDate()).padStart(2, '0');
      return `${y}-${m}-${d}`;
    }

    // 3) 문자열 패턴 처리
    const s = String(raw).trim();
    if (!s) return '';

    // 3-1) YYYY-MM-DD / YYYY/MM/DD / YYYY.M.D
    let m = s.match(/^(\d{4})[-\/\.](\d{1,2})[-\/\.](\d{1,2})$/);
    if (m) {
      const y = m[1];
      const mo = m[2].padStart(2, '0');
      const da = m[3].padStart(2, '0');
      return `${y}-${mo}-${da}`;
    }

    // 3-2) M/D/YY 또는 M/D/YYYY (예: 3/30/25, 3/30/2025)
    m = s.match(/^(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2}|\d{4})$/);
    if (m) {
      let y = m[3];
      if (y.length === 2) {
        const yy = parseInt(y, 10);
        // 엑셀/일반 관습: 00~29 -> 2000~2029, 그 외 -> 1900~1999 (필요시 규칙 조정)
        y = (yy <= 29 ? 2000 + yy : 1900 + yy).toString();
      }
      const mo = m[1].padStart(2, '0');
      const da = m[2].padStart(2, '0');
      return `${y}-${mo}-${da}`;
    }

    // 3-3) 기타 점/슬래시 혼용 (예: 25.3.30 -> 2025-03-30)도 커버하고 싶으면 여기에 추가 가능

    // 매칭 안 되면 원문 반환 (검증 단계에서 걸림)
    return s;
  }
async importData() {
    if (!this.rows.length) {
      this.showToast('Error', 'No Upload Data', 'error');
      return;
    }
    if (this.errors.length) {
      this.showToast('Error', 'Fix the validation errors first.', 'error');
      return;
    }
    this.isUploading = true;
    this.disableImport = true;
    try {
      const res = await upsertGlobal({ jsonRows: JSON.stringify(this.rows) });
      console.log('[Apex result]', JSON.stringify(res));

      if (res?.errors?.length) {
        this.errors = res.errors;
        this.showToast('Error', `Please check the error message.`, 'warning');
      } else {
        this.showToast('Success', `Opportunity ${res?.success || 0} record created`, 'success');
      }
    } catch (e) {
      this.showToast('Server Error', e?.body?.message || e?.message || 'lease contact the administrator.', 'error');
    } finally {
      this.isUploading = false;
      this.disableImport = this.rows.length === 0 || this.errors.length > 0;
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
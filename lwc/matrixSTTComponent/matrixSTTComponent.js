import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import findTasks from "@salesforce/apex/MatrixSttController.findTasks";
import updateTask from "@salesforce/apex/MatrixSttController.updateTask";
import updateCase from "@salesforce/apex/MatrixSttController.updateCase";
import updateSTTnTasknCase from "@salesforce/apex/MatrixSttController.updateSTTnTasknCase";
import updateLead from "@salesforce/apex/MatrixSttController.updateLead";
import updateWorkOrder from "@salesforce/apex/MatrixSttController.updateWorkOrder";

// import getFieldDependenciesForExt from "@salesforce/apex/MatrixCallController.getFieldDependenciesForExt";
import getFieldDependenciesForExt from "@salesforce/apex/MatrixCallController.getFieldDependenciesForExt";
import callId from "@salesforce/schema/Case.Matrix_Call_ID__c";

import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import findKnowledge from "@salesforce/apex/MatrixKnowledgeController.findKnowledge";

import { openTab } from "lightning/platformWorkspaceApi";
const columns = [
  {
    label: "키워드",
    fieldName: "URL",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "Title"
      },
      target: "_self"
    },
    sortable: true
  },
  { label: "Title", fieldName: "Title" }
];

export default class matrixSTTComponent extends LightningElement {
  @api recordId; // This property is automatically populated with the current record ID in a record context
  @api layoutTypes; // This property is automatically populated with the current record ID in a record context
  @track uid = "";
  caseNumber = "";
  iframeWindow = null;
  caseId = "";
  showIframe = true;
  tempList;
  iframeUrl = ""; 
  @track recordType = "Case";

  @track lockState = false;
  @track lockStateDisabled = false;

  @track badgeList = [];

  @track lock = "utility:unlock";
  handleLockButtonClick() {
    this.lockState = !this.lockState;
    if (this.lockState) this.lock = "utility:lock";
    else this.lock = "utility:unlock";
  }

  openKnowledgeTab() {
    const url = `/lightning/o/Knowledge__kav/list?filterName=dns&str=${encodeURIComponent(
      `Title:matrix`
    )}`;

    openTab({
      url: url,
      label: "Knowledge",
      focus: true
    }).catch((error) => {
      console.log(error);
    });
  }

  columns = columns;

  @api searchKey = "";

  @wire(getRecord, {
    recordId: "$recordId",
    layoutTypes: ["Full"],
    modes: ["View"],
    optionalFields: [callId]
  })
  wiredRecord({ error, data }) {
    if (data) {
      this.objectApiName = data.apiName;
      // console.log("this.objectApiName1  = ", this.objectApiName);
      // console.log('data',JSON.stringify(data))
      if (data.fields && data.fields.Matrix_Call_ID__c) {
        this.uid = data.fields.Matrix_Call_ID__c.value;
        console.log("this.callId =", this.uid);
        this.refreshIframe();
      } else {
        console.log("CallId is not available in the data fields.");
      }

      this.recordType = this.objectApiName;
    } else if (error) {
      console.error(error);
    }
  }
  case;

  @wire(findTasks, { searchKey: "$searchKey" })
  tasks;

  constructor() {
    super();
    window.addEventListener("message", this.receiveMessage.bind(this));
  }

  connectedCallback() {}

  renderedCallback() {
    console.log("The component has been renderedCallback case", this.case);
    console.log("The component has been renderedCallback task", this.tasks);
    this.iframeWindow = this.template.querySelector("iframe").contentWindow;
  }

  // sendMessageToIframe() {
  //   // const message = { 'type': 'CASEID', 'text': String(this.recordId) };
  //   // const msg = { 'type':'caseId','text': this.recordId}
  //   // console.log("recoredId type",typeof this.recordId,typeof message, typeof msg)
  //   // console.log("send iframewindow",msg,message);
  //   this.iframeWindow.postMessage(this.recordId, "*");
  // }

  sendMessageToIframe(sendData) {
    console.log("sendMessageToIframe  = ", sendData);
    const iframe = this.template.querySelector("iframe");
    if (iframe) {
      iframe.contentWindow.postMessage(
        sendData,
        "https://mtstt.matrixcloud.kr"
      );
    }
  }

  async receiveMessage(event) {
    //  console.log("lko Received message from chatbox iframe:", event);
    // Always verify the origin of the message
    const { data: orgData = {}, origin = "" } = event;
    const { type, data = {} } = orgData;
    const { providerId = "" } = data;

    //console.log("type  = ", type);
    // console.log(
    //   "origin  = ",
    //   origin,
    //   "this.recordId = ",
    //   this.recordId,
    //   "providerId = ",
    //   providerId,
    //   "is TURE ?",
    //   this.recordId !== providerId
    // );

    if (
      origin !== "https://mtstt.matrixcloud.kr" &&
      origin !== "https://mtsttdev.matrixcloud.kr"
    ) {
      //console.log("return Invalid origin!! ");
      return;
    }

    if (this.recordId !== providerId && type !== "UPDATE_KNOW_LIST") {
      console.log("return RecordId or ProviderId mismatch!! ");
      return;
    }

    switch (type) {
      case "UPDATE_KNOW_LIST":
        if (data) {
          if (!this.lockState) this.fnkeywordConv(data);
        }
        break;

      // case "UPDATE_IS_CONNECT":
      //   this.isConnect = data;
      //   break;

      case "FIND_UID_TO_TASK":
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.searchKey = data;
        break;

      case "GET_TASK_ID":
        console.log("this.2searchKey  = ", this.searchKey);
        break;

      case "GET_KNOW_LIST":
        this.showToast(
          "Success!!",
          "find Knowledge successfully!!",
          "success",
          "dismissable"
        );

        //this.tempList = this.findKnowledge(this.searchKey);
        this.fnFindKnowledge();
        //console.log("this.knowledge  = ", this.tempList);
        break;

      case "UID_TO_TASK_UPDATE":
        this.updateTask({ ...data });
        console.log("rtnUpdateTask  = ");
        break;

      case "UID_TO_CASE_UPDATE":
        console.log("UID_TO_CASE_UPDATE1  = ");

        if (this.recordType === "Lead") {
          console.log("updateLead  = ", this.recordType);
          this.updateLead({ ...data });
        } else if (this.recordType === "WorkOrder") {
          console.log("updateWorkOrder  = ", this.recordType,JSON.stringify(data));
          this.updateWorkOrder({ ...data });
        } else {
          console.log("updateCase  = ", this.recordType);
          this.updateSTT({ ...data });
        }

        break;

      case "GET_FIELD_DEPENDENCIES":
        this.fnGetFieldDependencies();

        console.log("rtnUpdateTask  = ");
        break;

      default:
        console.log("TYPE is not entered!");
        break;
    }

    //parent.postMessage({ type: 'FIND_UID_TO_TASK', data: "102-1700315655.1807" }, '*')
    //parent.postMessage({ type: 'GET_TASK_ID', data: "" }, '*')
    //parent.postMessage({ type: 'UID_TO_TASK_UPDATE', data: "" }, '*')
  }

  async fnGetFieldDependencies() {
    const rtn = await getFieldDependenciesForExt({
      objectName: "Task",
      controllingField: "ConsultationTypeMajor__c",
      dependentField: "ConsultationTypeMiddle__c"
    });

    this.sendMessageToIframe(
      JSON.stringify({ type: "FIELD_DEPENDENCIES_RESPONSE", data: rtn })
    );

    console.log("rtnGetFieldDependencies  = ", rtn);
    return rtn;
  }

  fnkeywordConv(key) {
    const newBadgeList = this.badgeList;

    if (newBadgeList.length > 0) {
      if (!newBadgeList.find((existingBadge) => existingBadge.id === key)) {
        newBadgeList.push({ id: key });
        if (newBadgeList.length > 4) newBadgeList.shift();
      }
    } else {
      newBadgeList.push({ id: key });
      if (newBadgeList.length > 4) newBadgeList.shift();
    }

    this.badgeList = [...newBadgeList];
  }

  async fnFindKnowledge(event) {
    const searchKey = event.target.dataset.id;
    console.log("fnFindKnowledge searchKey = ", searchKey);
    const tmpKnowledge = await findKnowledge({ searchKey });

    ///lightning/r/Knowledge__kav/ka01m000000BGPOAA4/view

    const knowledge = tmpKnowledge.map((k) => {
      const { Id } = k;
      const url = `/lightning/r/Knowledge__kav/${Id}/view`;

      return { ...k, URL: url };
    });
    console.log("knowledge1  = ", knowledge);
    this.tempList = knowledge;

    return knowledge;
  }

  async updateTask(params) {
    const { summary, emotion, category } = params;

    //const taskList = await findTasks({ searchKey: uid });
    //console.log("taskList  = ", taskList);
    //console.log("updateTask this.tasks.data[0].Id  = ", this.tasks.data[0].Id);
    const taskToUpdate = {
      Id: this.tasks.data[0].Id,
      call_summary__c: summary, // Replace with your data
      call_emotion__c: emotion, // Replace with your data
      call_category__c: category // Replace with your data
    };

    console.log("TaskUpdate Object:", taskToUpdate);
    updateTask({ taskUpdate: [{ ...taskToUpdate }] })
      .then((result) => {
        // Handle successful update
        console.log("Task updated successfully:", result);
      })
      .catch((error) => {
        // Handle update error
        console.error("Error updating task:", error);
      });
  }

  updateCase(params) {
    const { summary, emotion, category, uid } = params;
    console.log("updateCase this.tasks.data[0].Id  = ", this.recordId);
    const caseToUpdate = {
      Id: this.recordId,
      // Call_ID__c: uid,
      // call_summary__c: summary, // Replace with your data
      // call_emotion__c: emotion, // Replace with your data
      // call_category__c: category // Replace with your data
      Matrix_Call_ID__c: uid,
      Matrix_Call_Category__c: category, // Replace with your data
      Matrix_Call_Emotion__c: emotion, // Replace with your data
      Matrix_Call_Summary__c: summary // Replace with you
    };

    console.log("CaseUpdate Object:", caseToUpdate);
    updateCase({ caseUpdate: [{ ...caseToUpdate }] })
      .then((result) => {
        // Handle successful update
        console.log("Case updated successfully:", result);
        this.showToast(
          "Success!!",
          "Case updated successfully!!",
          "success",
          "dismissable"
        );
        this.dispatchEvent(new RefreshEvent());
      })
      .catch((error) => {
        // Handle update error
        console.error("Error updating case:", error);
      });
  }

  updateSTT(params) {
    const { summary, emotion, category, uid } = params;
    console.log("updateCase this.tasks.data[0].Id  = ", this.recordId);
    const sttUpdate = JSON.stringify({
      recordId: this.recordId,
      uid,
      category, // Replace with your data
      emotion, // Replace with your data
      summary // Replace with you
    });

    console.log("CaseUpdate Object:", sttUpdate);
    updateSTTnTasknCase({ sttUpdate })
      .then((result) => {
        // Handle successful update
        console.log("Case updated successfully:", result);
        this.showToast(
          "Success!!",
          "Case updated successfully!!",
          "success",
          "dismissable"
        );
        this.dispatchEvent(new RefreshEvent());
      })
      .catch((error) => {
        // Handle update error
        console.error("Error updating case:", error);
      });
  }

  updateWorkOrder(params) {
    const { summary, emotion, category, uid } = params;

    const sttUpdate = JSON.stringify({
      recordId: this.recordId,
      uid,
      category, // Replace with your data
      emotion, // Replace with your data
      summary // Replace with you
    });

    console.log("updateWorkOrder Object:", sttUpdate);
    updateWorkOrder({ sttUpdate })
      .then((result) => {
        // Handle successful update
        console.log("Case updated successfully:", result);
        this.showToast(
          "Success!!",
          "Case updated successfully!!",
          "success",
          "dismissable"
        );
        this.dispatchEvent(new RefreshEvent());
      })
      .catch((error) => {
        // Handle update error
        console.error("Error updating case:", error);
      });
  }

  updateLead(params) {
    const { summary, emotion, category, uid } = params;
    console.log("updateLead Lead Id  = ", this.recordId);
    const leadToUpdate = {
      Id: this.recordId,
      Matrix_Call_ID__c: uid,
      Matrix_Call_Category__c: category, // Replace with your data
      Matrix_Call_Emotion__c: emotion, // Replace with your data
      Matrix_Call_Summary__c: summary // Replace with your data
    };

    console.log("LeadUpdate Object:", leadToUpdate);
    updateLead({ leadUpdate: [{ ...leadToUpdate }] })
      .then((result) => {
        // Handle successful update
        console.log("Lead updated successfully:", result);
        this.showToast(
          "Success!!",
          "Lead updated successfully!!",
          "success",
          "dismissable"
        );
        this.dispatchEvent(new RefreshEvent());
      })
      .catch((error) => {
        // Handle update error
        console.error("Error updating Lead:", error);
      });
  }

  // get iframeUrl() {
  //   console.log(
  //     "this.objectApiName2  = ",
  //     this.recordType,
  //     " ",
  //     this.recordId,
  //     " ",
  //     this.uid
  //   );
  //   return (
  //     "https://mtstt.matrixcloud.kr?caseId=" +
  //     this.recordId +
  //     `&sttId=${this.uid}` +
  //     "&providerType=salesforce&baseCenterUserid=dns" +
  //     `&recordType=${this.recordType}`
  //   );
  // }

  showToast(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }

  refreshIframe() {
    const iframe = this.template.querySelector('iframe');
    if (iframe) {
      const currentSrc = "https://mtstt.matrixcloud.kr?caseId=" +
      this.recordId +
      `&sttId=${this.uid}` +
      "&providerType=salesforce&baseCenterUserid=dns" +
      `&recordType=${this.recordType}`;
      iframe.src = '';
      console.log("currentSrc  = ", currentSrc);
      setTimeout(() => {
        iframe.src = currentSrc;
      }, 10);
    }
  }
}
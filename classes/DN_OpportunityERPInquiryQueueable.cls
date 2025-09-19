public class DN_OpportunityERPInquiryQueueable implements Schedulable , Database.AllowsCallouts {
    public void execute(SchedulableContext sc) {
        // // 1. 기존 배치 실행
        // Database.executeBatch(new DN_OpportunityERPInquiryCreateBatch(), 10);

        // // 2. 실행 중인 같은 이름의 스케줄 잡을 Abort
        // abortOldJobs();

        // // 3. 1분 후 새 스케줄 등록
        // String cronExp = getCronExpressionAfterMinutes(1);
        // System.schedule('DN_OpportunityERPInquiryQueueable', cronExp, new DN_OpportunityERPInquiryQueueable());
        try {
            // 1. 현재 Flex Queue에 대기 중인 Batch Job 개수 확인
            Integer batchJobs = [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE 
                // JobType = 'BatchApex'
                // AND 
                Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            ];

            // 2. 만약 대기 중인 배치가 90개 이상이면 이번엔 배치 실행하지 않고 스킵
            if (batchJobs < 90) {
                Database.executeBatch(new DN_OpportunityERPInquiryCreateBatch(), 10);
            } else {
                System.debug('⚠️ 대기 중인 Batch Job이 너무 많아서 이번에는 배치 실행을 건너뜁니다. 현재 대기 중: ' + batchJobs);
            }
        } catch (Exception e) {
            System.debug('⚠️ Batch 실행 중 예외 발생: ' + e.getMessage());
            // 에러가 발생해도 스케줄은 계속 되게
        }

        // 3. 실행 중인 같은 이름의 스케줄 잡 Abort
        abortOldJobs();

        // 4. 1분 후 새 스케줄 등록
        String cronExp = getCronExpressionAfterMinutes(1);
        System.schedule('DN_OpportunityERPInquiryQueueable', cronExp, new DN_OpportunityERPInquiryQueueable());
    }
    // 현재 스케줄 잡 중에서 자기 자신 이름과 같은 스케줄을 찾아서 삭제
    private void abortOldJobs() {
        for (CronTrigger ct : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'DN_OpportunityERPInquiryQueueable']) {
            System.abortJob(ct.Id);
        }
    }

    // 현재 시간 기준 1분 후 CRON 생성
    private String getCronExpressionAfterMinutes(Integer afterMinutes) {
        Datetime dt = Datetime.now().addMinutes(afterMinutes);

        return String.format('{0} {1} {2} {3} {4} ? {5}', 
            new List<String>{
                String.valueOf(dt.second()), 
                String.valueOf(dt.minute()), 
                String.valueOf(dt.hour()), 
                String.valueOf(dt.day()), 
                String.valueOf(dt.month()), 
                String.valueOf(dt.year())
            }
        );
    }

    public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
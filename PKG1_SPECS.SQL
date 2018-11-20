CREATE OR REPLACE PACKAGE SCHEMA.PKG_00000 IS

  TYPE TRAINING_TRAININGS_REC IS RECORD(
    SCHEDULE_MASTER_ID SCHEMA.TABLE.SCHEDULE_MASTER_ID%TYPE,
    BRIEF_DESCRIPTION  SCHEMA.TABLE.BRIEF_DESCRIPTION%TYPE,
    SUBJECT_ID         SCHEMA.TABLE.SUBJECT_ID%TYPE,
    SUBJECT_DESC       SCHEMA.TABLE.DESCRIPTION%TYPE,
    
    AVAILABLE_SEATS            SCHEMA.TABLE.AVAILABLE_SEATS%TYPE,
    NOMINEES_SUBMISSION_DATE   SCHEMA.TABLE.NOMINEES_SUBMISSION_DATE%TYPE,
    TRAINING_VALIDITY_DATE     SCHEMA.TABLE.TRAINING_VALIDITY_DATE%TYPE,
    TENTATIVE_FROM_DATE        SCHEMA.TABLE.TENTATIVE_FROM_DATE%TYPE,
    TENTATIVE_TO_DATE          SCHEMA.TABLE.TENTATIVE_TO_DATE%TYPE,
    ACTUAL_FROM_DATE           SCHEMA.TABLE.ACTUAL_FROM_DATE%TYPE,
    ACTUAL_TO_DATE             SCHEMA.TABLE.ACTUAL_TO_DATE%TYPE,
    ORGANIZER_CODE             SCHEMA.TABLE.ORGANIZER_CODE%TYPE,
    ORGANIZER_NAME             SCHEMA.TABLE.NAME%TYPE,
    ORGANIZING_DEPT_ID         SCHEMA.TABLE.ORGANIZING_DEPT_ID%TYPE,
    ORGANIZING_DEPARTMENT_DESC SCHEMA.TABLE.DESCRIPTION%TYPE,
    APPROVAL_REQUIRED          SCHEMA.TABLE.APPROVAL_REQUIRED%TYPE,
    APPROVED_BY_CODE           SCHEMA.TABLE.APPROVED_BY_CODE%TYPE,
    ACTIVE                     SCHEMA.TABLE.ACTIVE%TYPE,
    REMARKS                    SCHEMA.TABLE.REMARKS%TYPE);
  TYPE TRAININGS_TABLE IS TABLE OF TRAINING_TRAININGS_REC INDEX BY PLS_INTEGER;
  TYPE PF_TRAININGS IS TABLE OF TRAINING_TRAININGS_REC;

  FUNCTION F_PIPLINED_FUNCTION(P_SCHEDULE_MASTER_ID SCHEMA.TABLE.SCHEDULE_MASTER_ID%TYPE)
    RETURN PF_TRAININGS
    PIPELINED;

  PROCEDURE QUERY_PROCEDURE(P_RESULT             IN OUT TRAININGS_TABLE,
                                P_SCHEDULE_MASTER_ID SCHEMA.TABLE.SCHEDULE_MASTER_ID%TYPE,
                                P_LOCTION_ID         IN VARCHAR2,
                                P_CALLING_OBJECT     IN VARCHAR2,
                                P_CALLING_USER       IN VARCHAR2,
                                P_CALLING_EVENT      IN VARCHAR2,
                                P_ERROR              OUT VARCHAR2);
  ------------------------------------------------------------------------------------------------

  PROCEDURE INSERT_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2,
                                P_COUNTER_ID     IN OUT VARCHAR2);
  ------------------------------------------------------------------------------------------------
  PROCEDURE UPDATE_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2);
  ------------------------------------------------------------------------------------------------
  PROCEDURE DELETE_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2);
  ------------------------------------------------------------------------------------------------
  PROCEDURE LOCK_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2);
  ------------------------------------------------------------------------------------------------
END PKG_00000;
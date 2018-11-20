CREATE OR REPLACE PACKAGE BODY SCHEMA.PKG_00000 IS
  PLC_SCHEMA CONSTANT VARCHAR2(50) := SYS_CONTEXT('USER',
                                                  'CURRENT_SCHEMA');

  EX_CUSTOM EXCEPTION;
  PLC_LF              CONSTANT VARCHAR2(10) := CHR(10) || '  . ';
  C_MyName            CONSTANT VARCHAR2(1000) := PLC_SCHEMA || '.' ||
                                                 $$PLSQL_UNIT || '.';
  C_ORGANIZATION_ID   CONSTANT SCHEMA.ORGANIZATION.ORGANIZATION_ID%TYPE := SYS_CONTEXT('GLOBAL_CONTEXT',
                                                                                            'ORGANIZATION_ID');
  C_LOCATION_ID       CONSTANT SCHEMA.LOCATION.LOCATION_ID%TYPE := SYS_CONTEXT('GLOBAL_CONTEXT',
                                                                                    'LOCATION_ID');
  C_ORDER_LOCATION_ID CONSTANT SCHEMA.ORDER_LOCATION.ORDER_LOCATION_ID%TYPE := SYS_CONTEXT('GLOBAL_CONTEXT',
                                                                                                'ORDER_LOCATION_ID');
  C_ZONE_ID           CONSTANT SCHEMA.LOCATION.ZON_ID%TYPE := SYS_CONTEXT('GLOBAL_CONTEXT',
                                                                               'ZONE_ID');

  /***********************************************************************************************
         PROCEDURE NAME: QUERY
         PURPOSE: This procedure is used to query data.
         ----------------------------------------------------------------------------------
         REVISIONS:
         Ver        Date         Author                  Description
         ---------  ----------   ---------------         -----------------------------------
         1.0        18-AUG-2017  Athar Islam            1. Created this Procedure.
  ************************************************************************************************/
  FUNCTION F_PIPLINED_FUNCTION(P_SCHEDULE_MASTER_ID SCHEMA.TABLE.SCHEDULE_MASTER_ID%TYPE)
    RETURN PF_TRAININGS
    PIPELINED AS
  BEGIN
    FOR V_ROW IN (SELECT SCHEDULE_MASTER_ID,
                         BRIEF_DESCRIPTION,
                         SUBJECT_ID,
                         SCHEMA.PKG_0000.f_get_training_description(p_subject_id => SUBJECT_ID) SUBJECT_DESC,
                         AVAILABLE_SEATS,
                         NOMINEES_SUBMISSION_DATE,
                         TRAINING_VALIDITY_DATE,
                         TENTATIVE_FROM_DATE,
                         TENTATIVE_TO_DATE,
                         ACTUAL_FROM_DATE,
                         ACTUAL_TO_DATE,
                         ORGANIZER_CODE,
                         SCHEMA.PKG_0000000.GET_PATIENT_NAME(ORGANIZER_CODE) ORGANIZER_NAME,
                         ORGANIZING_DEPT_ID,
                         hrd.PKG_0000.get_department_name(p_department_id => ORGANIZING_DEPT_ID) ORGANIZING_DEPARTMENT_DESC,
                         APPROVAL_REQUIRED,
                         APPROVED_BY_CODE,
                         ACTIVE,
                         REMARKS
                    FROM SCHEMA.TABLE T
                   WHERE NVL(T.SCHEDULE_MASTER_ID, '$') =
                         NVL(P_SCHEDULE_MASTER_ID,
                             NVL(T.SCHEDULE_MASTER_ID, '$')))
    
     LOOP
      PIPE ROW(V_ROW);
    END LOOP;
  END F_PIPLINED_FUNCTION;

  PROCEDURE QUERY_PROCEDURE(P_RESULT             IN OUT TRAININGS_TABLE,
                                P_SCHEDULE_MASTER_ID SCHEMA.TABLE.SCHEDULE_MASTER_ID%TYPE,
                                P_LOCTION_ID         IN VARCHAR2,
                                P_CALLING_OBJECT     IN VARCHAR2,
                                P_CALLING_USER       IN VARCHAR2,
                                P_CALLING_EVENT      IN VARCHAR2,
                                P_ERROR              OUT VARCHAR2) AS
  
    C_MyName CONSTANT VARCHAR2(1000) := SYS_CONTEXT('USER',
                                                    'CURRENT_SCHEMA') || '.' ||
                                        $$PLSQL_UNIT || '.TRAININGS_QRY';
  
    V_MESG_Text VARCHAR2(4000);
    V_PARA_Text VARCHAR2(4000);
    V_CALL_Text VARCHAR2(1000) := 'Calling Object: ' || P_CALLING_OBJECT ||
                                  PLC_LF || 'Calling User: ' ||
                                  P_CALLING_USER || PLC_LF ||
                                  'Calling Event: ' || P_CALLING_EVENT;
  
  BEGIN
  
    SELECT *
      BULK COLLECT
      INTO P_RESULT
      FROM TABLE(SCHEMA.PKG_0000000.F_SCHEDULE_MASTER(P_SCHEDULE_MASTER_ID => P_SCHEDULE_MASTER_ID));
  
  EXCEPTION
  
    WHEN EX_CUSTOM THEN
      RAISE_APPLICATION_ERROR(-20007, '~~~' || P_ERROR || '~~~');
    WHEN OTHERS THEN
      P_ERROR := 'Error during Procedure ' || C_MyName || 'EVENT: ' ||
                 P_CALLING_EVENT || ' execution at line:  ' || $$PLSQL_LINE ||
                 CHR(10) || 'Error: ' || SQLERRM;
    
      V_MESG_Text := ' - Procedure: ' || C_MyName || PLC_LF ||
                     'Description: Unknown Error' || PLC_LF || V_CALL_Text ||
                     PLC_LF || 'Parameter: ' || V_PARA_Text || PLC_LF ||
                     'P_ERROR: ' || P_ERROR;
      HIS.MESSAGE_ENTRY(V_MESG_Text);
    
      RAISE_APPLICATION_ERROR(-20007, '~~~' || P_ERROR || '~~~');
    
  END QUERY_PROCEDURE;

  /***********************************************************************************************
         PROCEDURE NAME: INSERT
         PURPOSE: This procedure is used to INSERT data.
         ----------------------------------------------------------------------------------
         REVISIONS:
         Ver        Date         Author                  Description
         ---------  ----------   ---------------         -----------------------------------
         1.0        18-AUG-2017  Athar Islam            1. Created this Procedure.
  ************************************************************************************************/

  PROCEDURE INSERT_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2,
                                P_COUNTER_ID     IN OUT VARCHAR2) AS
  
    C_MyName CONSTANT VARCHAR2(1000) := SYS_CONTEXT('USER',
                                                    'CURRENT_SCHEMA') || '.' ||
                                        $$PLSQL_UNIT || '.TRAININGS_INS';
    V_PARA_Text VARCHAR2(2000);
    V_MESG_Text VARCHAR2(4000);
    V_CALL_Text VARCHAR2(1000) := 'Calling Object: ' || P_CALLING_OBJECT ||
                                  PLC_LF || 'Calling User: ' ||
                                  P_CALLING_USER || PLC_LF ||
                                  'Calling Event: ' || P_CALLING_EVENT;
  
    V_INDEX    PLS_INTEGER;
    V_ERROR    VARCHAR2(4000);
    V_ROW      SCHEMA.TABLE%rowtype;
    V_TOPIC_ID VARCHAR2(9);
  
  BEGIN
  
    BEGIN
    
      IF NOT
          SCHEMA.PKG_0000.f_get_counter_id(p_counter_key    => 'SCHEMA.TABLE.SCHEDULE_MASTER_ID',
                                               p_counter_loc    => C_ORDER_LOCATION_ID,
                                               p_where          => NULL,
                                               p_value          => V_TOPIC_ID,
                                               p_location_id    => P_LOCATION_ID,
                                               p_calling_object => P_CALLING_OBJECT,
                                               p_calling_user   => P_CALLING_USER,
                                               p_calling_event  => P_CALLING_EVENT,
                                               p_error          => P_ERROR)
      
       THEN
        HIS.MESSAGE_ENTRY('SCHEMA.TABLE.SCHEDULE_MASTER_ID' ||
                          'SQLERRM :' || SQLERRM || P_ERROR ||
                          'V_TOPIC_ID' || V_TOPIC_ID);
      END IF;
    
    END;
  
    V_INDEX := P_RESULT.FIRST;
    LOOP
      BEGIN
        P_COUNTER_ID := V_TOPIC_ID;
      
        V_ROW.SCHEDULE_MASTER_ID       := V_TOPIC_ID;
        V_ROW.BRIEF_DESCRIPTION        := P_RESULT(V_INDEX)
                                          .BRIEF_DESCRIPTION;
        V_ROW.SUBJECT_ID               := P_RESULT(V_INDEX).SUBJECT_ID;
        V_ROW.AVAILABLE_SEATS          := P_RESULT(V_INDEX).AVAILABLE_SEATS;
        V_ROW.NOMINEES_SUBMISSION_DATE := P_RESULT(V_INDEX)
                                          .NOMINEES_SUBMISSION_DATE;
        V_ROW.TRAINING_VALIDITY_DATE   := P_RESULT(V_INDEX)
                                          .TRAINING_VALIDITY_DATE;
        V_ROW.TENTATIVE_FROM_DATE      := P_RESULT(V_INDEX)
                                          .TENTATIVE_FROM_DATE;
        V_ROW.TENTATIVE_TO_DATE        := P_RESULT(V_INDEX)
                                          .TENTATIVE_TO_DATE;
        V_ROW.ACTUAL_FROM_DATE         := P_RESULT(V_INDEX).ACTUAL_FROM_DATE;
        V_ROW.ACTUAL_TO_DATE           := P_RESULT(V_INDEX).ACTUAL_TO_DATE;
        V_ROW.ORGANIZER_CODE           := P_RESULT(V_INDEX).ORGANIZER_CODE;
        V_ROW.ORGANIZING_DEPT_ID       := P_RESULT(V_INDEX)
                                          .ORGANIZING_DEPT_ID;
        V_ROW.APPROVAL_REQUIRED        := P_RESULT(V_INDEX)
                                          .APPROVAL_REQUIRED;
        V_ROW.APPROVED_BY_CODE         := P_RESULT(V_INDEX).APPROVED_BY_CODE;
        V_ROW.ACTIVE                   := P_RESULT(V_INDEX).ACTIVE;
        V_ROW.REMARKS                  := P_RESULT(V_INDEX).REMARKS;
        V_ROW.ORG_ID                   := C_ORGANIZATION_ID;
        V_ROW.ZON_ID                   := C_ZONE_ID;
        V_ROW.LOC_ID                   := C_LOCATION_ID;
      
        IF NOT
            SCHEMA.PKG_TABLE.F_INSERT(P_ROW              => V_ROW,
                                                  P_IGNORE_DUPLICATE => 'Y',
                                                  P_LOCATION_ID      => P_LOCATION_ID,
                                                  P_CALLING_OBJECT   => P_CALLING_OBJECT,
                                                  P_CALLING_USER     => P_CALLING_USER,
                                                  P_CALLING_EVENT    => P_CALLING_EVENT,
                                                  P_ERROR            => P_ERROR) THEN
        
          RAISE EX_CUSTOM;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        
          P_ERROR := 'Error during Procedure' || C_MyName ||
                     'execution at line: ' || $$plsql_line || CHR(10) ||
                     'error ' || SQLERRM;
        
          V_MESG_TEXT := 'TRAINING - Procedure: ' || C_MyName || PLC_LF ||
                         'Description: Other Exception' || PLC_LF ||
                         'Object: TRAINING' || PLC_LF || 'Parameters:' ||
                         V_PARA_Text || PLC_LF || 'P_ERROR ' || P_ERROR;
          RAISE EX_CUSTOM;
      END;
      EXIT WHEN V_INDEX = P_RESULT.LAST;
      V_INDEX := P_RESULT.NEXT(V_INDEX);
    END LOOP;
  
  EXCEPTION
    WHEN EX_CUSTOM THEN
      P_ERROR := V_ERROR;
      RAISE_APPLICATION_ERROR(-2007, '~~~' || P_ERROR || '~~~');
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-2007, '~~~' || P_ERROR || '~~~');
    WHEN OTHERS THEN
      P_ERROR := 'Error during Procedure ' || C_MyName ||
                 ' execution at line:  ' || $$PLSQL_LINE || CHR(10) ||
                 'Error: ' || V_ERROR || SQLERRM;
    
      V_MESG_Text := 'TRAINING - Procedure: ' || C_MyName || PLC_LF ||
                     'Description: Unknown Error' || PLC_LF || V_CALL_Text ||
                     PLC_LF || 'Parameter: ' || V_PARA_Text || PLC_LF ||
                     'P_ERROR: ' || P_ERROR;
    
      HIS.MESSAGE_ENTRY(V_MESG_Text);
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20007, '~~~' || P_ERROR || '~~~');
    
  END INSERT_PROCEDURE;

  /***********************************************************************************************
         PROCEDURE NAME: UPDATE
         PURPOSE: This procedure is used to UPDATE data.
         ----------------------------------------------------------------------------------
         REVISIONS:
         Ver        Date         Author                  Description
         ---------  ----------   ---------------         -----------------------------------
         1.0        18-AUG-2017  Athar Islam            1. Created this Procedure.
  ************************************************************************************************/

  PROCEDURE UPDATE_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2) AS
  
    C_MyName CONSTANT VARCHAR2(1000) := SYS_CONTEXT('USER',
                                                    'CURRENT_SCHEMA') || '.' ||
                                        $$PLSQL_UNIT || '.UPDATE_PROCEDURE';
    V_PARA_Text VARCHAR2(2000);
    V_MESG_Text VARCHAR2(4000);
    V_CALL_Text VARCHAR2(1000) := 'Calling Object: ' || P_CALLING_OBJECT ||
                                  PLC_LF || 'Calling User: ' ||
                                  P_CALLING_USER || PLC_LF ||
                                  'Calling Event: ' || P_CALLING_EVENT;
  
    V_INDEX PLS_INTEGER;
    V_ERROR VARCHAR2(4000);
    V_ROW   SCHEMA.TABLE%rowtype;
  
  BEGIN
  
    V_INDEX := P_RESULT.FIRST;
    LOOP
      BEGIN
      
        V_ROW.SCHEDULE_MASTER_ID := P_RESULT(V_INDEX).SCHEDULE_MASTER_ID;
        V_ROW.BRIEF_DESCRIPTION  := P_RESULT(V_INDEX).BRIEF_DESCRIPTION;
        V_ROW.SUBJECT_ID         := P_RESULT(V_INDEX).SUBJECT_ID;
      
        V_ROW.AVAILABLE_SEATS          := P_RESULT(V_INDEX).AVAILABLE_SEATS;
        V_ROW.NOMINEES_SUBMISSION_DATE := P_RESULT(V_INDEX)
                                          .NOMINEES_SUBMISSION_DATE;
        V_ROW.TRAINING_VALIDITY_DATE   := P_RESULT(V_INDEX)
                                          .TRAINING_VALIDITY_DATE;
        V_ROW.TENTATIVE_FROM_DATE      := P_RESULT(V_INDEX)
                                          .TENTATIVE_FROM_DATE;
        V_ROW.TENTATIVE_TO_DATE        := P_RESULT(V_INDEX)
                                          .TENTATIVE_TO_DATE;
        V_ROW.ACTUAL_FROM_DATE         := P_RESULT(V_INDEX).ACTUAL_FROM_DATE;
        V_ROW.ACTUAL_TO_DATE           := P_RESULT(V_INDEX).ACTUAL_TO_DATE;
        V_ROW.ORGANIZER_CODE           := P_RESULT(V_INDEX).ORGANIZER_CODE;
        V_ROW.ORGANIZING_DEPT_ID       := P_RESULT(V_INDEX)
                                          .ORGANIZING_DEPT_ID;
        V_ROW.APPROVAL_REQUIRED        := P_RESULT(V_INDEX)
                                          .APPROVAL_REQUIRED;
        V_ROW.APPROVED_BY_CODE         := P_RESULT(V_INDEX).APPROVED_BY_CODE;
        V_ROW.ACTIVE                   := P_RESULT(V_INDEX).ACTIVE;
        V_ROW.REMARKS                  := P_RESULT(V_INDEX).REMARKS;
      
        IF NOT
            SCHEMA.pkg_TABLE.f_update(p_schedule_master_id => P_RESULT(V_INDEX)
                                                                          .SCHEDULE_MASTER_ID,
                                                  p_row                => V_row,
                                                  p_update_null        => 'Y',
                                                  p_ignore_no_data     => 'Y',
                                                  p_location_id        => p_location_id,
                                                  p_calling_object     => p_calling_object,
                                                  p_calling_user       => p_calling_user,
                                                  p_calling_event      => p_calling_event,
                                                  p_error              => p_error) THEN
        
          RAISE EX_CUSTOM;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        
          P_ERROR := 'Error during Procedure' || C_MyName ||
                     'execution at line: ' || $$plsql_line || CHR(10) ||
                     'error ' || SQLERRM;
        
          V_MESG_TEXT := 'TRAINING - Procedure: ' || C_MyName || PLC_LF ||
                         'Description: Other Exception' || PLC_LF ||
                         'Object: TRAINING' || PLC_LF || 'Parameters:' ||
                         V_PARA_Text || PLC_LF || 'P_ERROR ' || P_ERROR;
          RAISE EX_CUSTOM;
      END;
      EXIT WHEN V_INDEX = P_RESULT.LAST;
      V_INDEX := P_RESULT.NEXT(V_INDEX);
    END LOOP;
  
  EXCEPTION
    WHEN EX_CUSTOM THEN
      P_ERROR := V_ERROR;
      RAISE_APPLICATION_ERROR(-2007, '~~~' || P_ERROR || '~~~');
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-2007, '~~~' || P_ERROR || '~~~');
    WHEN OTHERS THEN
      P_ERROR := 'Error during Procedure ' || C_MyName ||
                 ' execution at line:  ' || $$PLSQL_LINE || CHR(10) ||
                 'Error: ' || V_ERROR || SQLERRM;
    
      V_MESG_Text := 'TRAINING - Procedure: ' || C_MyName || PLC_LF ||
                     'Description: Unknown Error' || PLC_LF || V_CALL_Text ||
                     PLC_LF || 'Parameter: ' || V_PARA_Text || PLC_LF ||
                     'P_ERROR: ' || P_ERROR;
    
      HIS.MESSAGE_ENTRY(V_MESG_Text);
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20007, '~~~' || P_ERROR || '~~~');
    
  END UPDATE_PROCEDURE;

  /***********************************************************************************************
         PROCEDURE NAME: DELETE
         PURPOSE: This procedure is used to DELETE data.
         ----------------------------------------------------------------------------------
         REVISIONS:
         Ver        Date         Author                  Description
         ---------  ----------   ---------------         -----------------------------------
         1.0        18-AUG-2017  Athar Islam            1. Created this Procedure.
  ************************************************************************************************/
  PROCEDURE DELETE_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2) AS
  
    C_MyName CONSTANT VARCHAR2(1000) := SYS_CONTEXT('USER',
                                                    'CURRENT_SCHEMA') || '.' ||
                                        $$PLSQL_UNIT || '.DELETE_PROCEDURE';
    V_PARA_Text VARCHAR2(2000);
    V_MESG_Text VARCHAR2(4000);
    V_CALL_Text VARCHAR2(1000) := 'Calling Object: ' || P_CALLING_OBJECT ||
                                  PLC_LF || 'Calling User: ' ||
                                  P_CALLING_USER || PLC_LF ||
                                  'Calling Event: ' || P_CALLING_EVENT;
  
    V_INDEX PLS_INTEGER;
    V_ERROR VARCHAR2(4000);
    V_ROW   SCHEMA.TABLE%rowtype;
  
  BEGIN
  
    V_INDEX := P_RESULT.FIRST;
    LOOP
      BEGIN
      
        IF NOT
            SCHEMA.pkg_TABLE.f_delete(p_schedule_master_id => P_RESULT(V_INDEX)
                                                                          .SCHEDULE_MASTER_ID,
                                                  p_ignore_no_data     => 'Y',
                                                  p_location_id        => P_LOCATION_ID,
                                                  p_calling_object     => p_calling_object,
                                                  p_calling_user       => p_calling_user,
                                                  p_calling_event      => p_calling_event,
                                                  p_error              => p_error) THEN
        
          RAISE EX_CUSTOM;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        
          P_ERROR := 'Error during Procedure' || C_MyName ||
                     'execution at line: ' || $$plsql_line || CHR(10) ||
                     'error ' || SQLERRM;
        
          V_MESG_TEXT := 'TRAINING - Procedure: ' || C_MyName || PLC_LF ||
                         'Description: Other Exception' || PLC_LF ||
                         'Object: TRAINING' || PLC_LF || 'Parameters:' ||
                         V_PARA_Text || PLC_LF || 'P_ERROR ' || P_ERROR;
          RAISE EX_CUSTOM;
      END;
      EXIT WHEN V_INDEX = P_RESULT.LAST;
      V_INDEX := P_RESULT.NEXT(V_INDEX);
    END LOOP;
  
  EXCEPTION
    WHEN EX_CUSTOM THEN
      P_ERROR := V_ERROR;
      RAISE_APPLICATION_ERROR(-2007, '~~~' || P_ERROR || '~~~');
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-2007, '~~~' || P_ERROR || '~~~');
    WHEN OTHERS THEN
      P_ERROR := 'Error during Procedure ' || C_MyName ||
                 ' execution at line:  ' || $$PLSQL_LINE || CHR(10) ||
                 'Error: ' || V_ERROR || SQLERRM;
    
      V_MESG_Text := 'TRAINING - Procedure: ' || C_MyName || PLC_LF ||
                     'Description: Unknown Error' || PLC_LF || V_CALL_Text ||
                     PLC_LF || 'Parameter: ' || V_PARA_Text || PLC_LF ||
                     'P_ERROR: ' || P_ERROR;
    
      HIS.MESSAGE_ENTRY(V_MESG_Text);
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20007, '~~~' || P_ERROR || '~~~');
    
  END DELETE_PROCEDURE;

  /***********************************************************************************************
         PROCEDURE NAME: TRAININGS_LCK
         PURPOSE: This procedure is used to LOCK RECORD.
         ----------------------------------------------------------------------------------
         REVISIONS:
         Ver        Date         Author                  Description
         ---------  ----------   ---------------         -----------------------------------
         1.0        18-AUG-2017  Athar Islam            1. Created this Procedure.
  ************************************************************************************************/

  PROCEDURE LOCK_PROCEDURE(P_RESULT         IN OUT TRAININGS_TABLE,
                                P_LOCATION_ID    IN VARCHAR2,
                                P_CALLING_OBJECT IN VARCHAR2,
                                P_CALLING_USER   IN VARCHAR2,
                                P_CALLING_EVENT  IN VARCHAR2,
                                P_ERROR          OUT VARCHAR2) AS
  BEGIN
    NULL;
  END;
  END SCHEMA.PKG_00000;
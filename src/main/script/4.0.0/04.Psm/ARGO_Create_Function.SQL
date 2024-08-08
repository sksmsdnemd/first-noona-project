CREATE OR REPLACE PACKAGE "PK_AGENT" AS
	TYPE OB_AGENT IS RECORD(
		TENANT_ID          VARCHAR(50),
		AGENT_ID           VARCHAR(50),
		AGENT_NM           VARCHAR(100),
		AGENT_PW           VARCHAR(2048),
		SABUN              VARCHAR(20),
		DEPT_CD            VARCHAR(20),
		TM_KIND            VARCHAR(50),
		AGENT_JIKGUP       VARCHAR(50),
		AGENT_JIKCHK       VARCHAR(50),
		JIKJONG_KIND       VARCHAR(50),
		DAYNIGHT_GUBUN     VARCHAR(50),
		JAEJIK_GUBUN       VARCHAR(50),
		GENDER_KIND        VARCHAR(50),
		BIRTH_YMD          VARCHAR(8),
		ENTER_YMD          VARCHAR(8),
		RETIRE_YMD         VARCHAR(8),
		RETIRE_GUBUN       VARCHAR(50),
		RETIRE_RSN         VARCHAR(255),
		WORK_MONTH_PERIOD  NUMBER,
		HIDE_YN            NUMBER(1),
		LOGIN_TRY_COUNT    NUMBER,
		TEL_NO             VARCHAR(50),
		LOCK_YN            NUMBER(1),
		CONTRACT_FRM       VARCHAR(8),
		CONTRACT_END       VARCHAR(8),
		SCHE_TARGET_YN     NUMBER(1),
		EDU_TARGET_YN      NUMBER(1),
		QA_TARGET_YN       NUMBER(1),
		KPI_TARGET_YN      NUMBER(1),
		IMG_REAL_FILENAME  VARCHAR(255),
		IMG_USER_FILENAME  VARCHAR(255),
		IMG_PATH           VARCHAR(255),
		GRANT_ID           VARCHAR(50),
		WARNING_INFO       VARCHAR(50),
		USER_DATA1         VARCHAR(255),
		USER_DATA2         VARCHAR(255),
		USER_DATA3         VARCHAR(255),
		USER_DATA4         VARCHAR(255),
		USER_DATA5         VARCHAR(255),
		USER_DATA6         VARCHAR(255),
		USER_DATA7         VARCHAR(255),
		USER_DATA8         VARCHAR(255),
		USER_DATA9         VARCHAR(255),
		USER_DATA10        VARCHAR(255)
	);
	TYPE NT_AGENT IS TABLE OF OB_AGENT;
END;
/

;

CREATE OR REPLACE PACKAGE "PK_AGENT_HISTORY" AS
	TYPE OB_AGENT_HISTORY IS RECORD(
		TENANT_ID          VARCHAR(50),
		STD_MONTH          VARCHAR(6),
		AGENT_ID           VARCHAR(50),
		AGENT_NM           VARCHAR(100),
		AGENT_PW           VARCHAR(2048),
		SABUN              VARCHAR(20),
		DEPT_CD            VARCHAR(20),
		TM_KIND            VARCHAR(50),
		AGENT_JIKGUP       VARCHAR(50),
		AGENT_JIKCHK       VARCHAR(50),
		JIKJONG_KIND       VARCHAR(50),
		DAYNIGHT_GUBUN     VARCHAR(50),
		JAEJIK_GUBUN       VARCHAR(50),
		GENDER_KIND        VARCHAR(50),
		BIRTH_YMD          VARCHAR(8),
		ENTER_YMD          VARCHAR(8),
		RETIRE_YMD         VARCHAR(8),
		RETIRE_GUBUN       VARCHAR(50),
		RETIRE_RSN         VARCHAR(255),
		WORK_MONTH_PERIOD  NUMBER,
		HIDE_YN            NUMBER(1),
		LOGIN_TRY_COUNT    NUMBER,
		TEL_NO             VARCHAR(50),
		LOCK_YN            NUMBER(1),
		CONTRACT_FRM       VARCHAR(8),
		CONTRACT_END       VARCHAR(8),
		SCHE_TARGET_YN     NUMBER(1),
		EDU_TARGET_YN      NUMBER(1),
		QA_TARGET_YN       NUMBER(1),
		KPI_TARGET_YN      NUMBER(1),
		IMG_REAL_FILENAME  VARCHAR(255),
		IMG_USER_FILENAME  VARCHAR(255),
		IMG_PATH           VARCHAR(255),
		GRANT_ID           VARCHAR(50),
		WARNING_INFO       VARCHAR(50),
		USER_DATA1         VARCHAR(255),
		USER_DATA2         VARCHAR(255),
		USER_DATA3         VARCHAR(255),
		USER_DATA4         VARCHAR(255),
		USER_DATA5         VARCHAR(255),
		USER_DATA6         VARCHAR(255),
		USER_DATA7         VARCHAR(255),
		USER_DATA8         VARCHAR(255),
		USER_DATA9         VARCHAR(255),
		USER_DATA10        VARCHAR(255)
	);
	TYPE NT_AGENT_HISTORY IS TABLE OF OB_AGENT_HISTORY;
END;
/

;

CREATE OR REPLACE PACKAGE "PK_DEPT" AS
	TYPE OB_DEPT IS RECORD(
		TENANT_ID VARCHAR(50),
		DEPT_CD	 VARCHAR(20),
		DEPT_NM	VARCHAR(20),
		DEPT_DEPTH	NUMBER,
		PARENT_DEPT_CD	VARCHAR(20),
		CENTER_KIND VARCHAR(50),
		COM_KIND VARCHAR(50),
		IN_OUT_KIND VARCHAR(50),
		SORT	NUMBER,
		HIDE_YN	NUMBER(1,0),
		CREATE_AGENT_ID	VARCHAR(50),
		CREATE_DT	DATE,
		MODIFY_AGENT_ID	VARCHAR(50),
		MODIFY_DT	DATE
	);
	TYPE NT_DEPT IS TABLE OF OB_DEPT;
END;
/

;

CREATE OR REPLACE PACKAGE "PK_DEPT_HISTORY" AS
	TYPE OB_DEPT_HISTORY IS RECORD(
		TENANT_ID VARCHAR(50),
		STD_MONTH VARCHAR(6),
		DEPT_CD	VARCHAR(20),
		DEPT_NM	VARCHAR(20),
		DEPT_DEPTH	NUMBER,
		PARENT_DEPT_CD	VARCHAR(20),
		CENTER_KIND VARCHAR(50),
		COM_KIND VARCHAR(50),
		IN_OUT_KIND VARCHAR(50),
		SORT	NUMBER,
		HIDE_YN	NUMBER(1,0),
		CREATE_AGENT_ID	VARCHAR(50),
		CREATE_DT	DATE,
		MODIFY_AGENT_ID	VARCHAR(50),
		MODIFY_DT	DATE
	);
	TYPE NT_DEPT_HISTORY IS TABLE OF OB_DEPT_HISTORY;
END;
/

;

CREATE OR REPLACE PACKAGE "PK_KPI_USER_MASTER" AS
	TYPE OB_KPI_USER_MASTER IS RECORD(
		TENANT_ID          VARCHAR2(50),
		AGENT_ID           VARCHAR2(50),
		AGENT_NM           VARCHAR2(100),
		AGENT_PW           VARCHAR2(2048),
		SABUN              VARCHAR2(20),
		DEPT_CD			   VARCHAR2(20),
		TM_KIND            VARCHAR2(50),
		AGENT_JIKGUP       VARCHAR2(50),
		AGENT_JIKCHK       VARCHAR2(50),
		JIKJONG_KIND       VARCHAR2(50),
		DAYNIGHT_GUBUN     VARCHAR2(50),
		JAEJIK_GUBUN       VARCHAR2(50),
		GENDER_KIND        VARCHAR2(50),
		BIRTH_YMD          VARCHAR2(8),
		ENTER_YMD          VARCHAR2(8),
		RETIRE_YMD         VARCHAR2(8),
		RETIRE_GUBUN       VARCHAR2(50),
		RETIRE_RSN         VARCHAR2(255),
		WORK_MONTH_PERIOD  NUMBER,
		HIDE_YN            NUMBER(1),
		LOGIN_TRY_COUNT    NUMBER,
		TEL_NO             VARCHAR2(50),
		LOCK_YN            NUMBER(1),
		CONTRACT_FRM       VARCHAR2(8),
		CONTRACT_END       VARCHAR2(8),
		SCHE_TARGET_YN     NUMBER(1),
		EDU_TARGET_YN      NUMBER(1),
		QA_TARGET_YN       NUMBER(1),
		KPI_TARGET_YN      NUMBER(1),
		IMG_REAL_FILENAME  VARCHAR2(255),
		IMG_USER_FILENAME  VARCHAR2(255),
		IMG_PATH           VARCHAR2(255),
		GRANT_ID           VARCHAR2(50),
		WARNING_INFO       VARCHAR2(50),
		USER_DATA1         VARCHAR2(255),
		USER_DATA2         VARCHAR2(255),
		USER_DATA3         VARCHAR2(255),
		USER_DATA4         VARCHAR2(255),
		USER_DATA5         VARCHAR2(255),
		USER_DATA6         VARCHAR2(255),
		USER_DATA7         VARCHAR2(255),
		USER_DATA8         VARCHAR2(255),
		USER_DATA9         VARCHAR2(255),
		USER_DATA10        VARCHAR2(255),

		CENTER_DEPT_NM	 VARCHAR2(20),
		PART_DEPT_NM	 VARCHAR2(20),
		TEAM_DEPT_NM	 VARCHAR2(20),
		JO_DEPT_NM	 VARCHAR2(20),
		CENTER_DEPT_CD	 VARCHAR2(20),
		PART_DEPT_CD	 VARCHAR2(20),
		TEAM_DEPT_CD	 VARCHAR2(20),
		JO_DEPT_CD	 VARCHAR2(20),
		CENTER_KIND VARCHAR2(50),
		COM_KIND VARCHAR2(50),
		IN_OUT_KIND VARCHAR2(50)
	);
	TYPE NT_KPI_USER_MASTER IS TABLE OF OB_KPI_USER_MASTER;
END;
/

;

CREATE OR REPLACE PACKAGE "PK_SPLIT" AS
	TYPE OB_SPLIT IS RECORD(
		idx number,
  		split_value varchar(4000)
	);
	TYPE NT_SPLIT IS TABLE OF OB_SPLIT;
END;
/

;

create or replace FUNCTION FN_CM_GET_AGENT_INFO
(
   I_TENANT_ID  IN VARCHAR2
 , I_AGENT_ID   IN VARCHAR2
)
RETURN VARCHAR2
IS
/******************************************************************************
   NAME:       FN_CM_GET_AGENT_INFO
   PURPOSE:    상담자명(사번) 형태로 리턴

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/01/20  YAKIM
******************************************************************************/
  V_RLT VARCHAR2(120):='' ;

BEGIN
 
 SELECT A.AGENT_NM|| '('||A.SABUN||')' INTO V_RLT
   FROM TB_CM_USER_MASTER A
  WHERE A.TENANT_ID = I_TENANT_ID
    AND A.AGENT_ID  = I_AGENT_ID
 ;
  RETURN V_RLT;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
    V_RLT := null;
    RETURN V_RLT;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);    
END;
/

;

create or replace function fn_cm_get_agent_nm
(  I_TENANT_ID      IN VARCHAR2
 , ps_agent_id in varchar2
)
return varchar2
is
  
  vs_agent_nm  VARCHAR2(100):='' ;

/*
agent_id 로 사용자 이름을 찾는다.
select fn_cm_get_agent_nm('10000') from dual;

*/
BEGIN
  vs_agent_nm := '';
  
  select nvl(agent_nm, '')
  into vs_agent_nm
  from tb_cm_user_master
  where TENANT_ID = I_TENANT_ID AND agent_id = ps_agent_id;
  
  
  
  return vs_agent_nm;
  
  exception 
  when NO_DATA_FOUND THEN
    vs_agent_nm := null;
    return vs_agent_nm;
  when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
    
end;
/

;

CREATE OR REPLACE FUNCTION FN_CM_GET_AGENT_SABUN
(
	I_TENANT_ID   IN VARCHAR2
	,PS_AGENT_ID  IN VARCHAR2
)
RETURN VARCHAR2 IS VS_AGENT_SABUN VARCHAR2(20) := '' ;

/*
SELECT FN_CM_GET_AGENT_SABUN('BT', '10000') FROM DUAL;
*/
BEGIN
	VS_AGENT_SABUN := '';
	
	SELECT NVL(SABUN, '')
	  INTO VS_AGENT_SABUN
	  FROM TB_CM_USER_MASTER
	 WHERE TENANT_ID = I_TENANT_ID 
	   AND AGENT_ID = PS_AGENT_ID;
	
	
	RETURN VS_AGENT_SABUN;
	
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
		VS_AGENT_SABUN := NULL;
		RETURN VS_AGENT_SABUN;
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('????????.');
		DBMS_OUTPUT.PUT_LINE('SQL ERROR CODE : ' || SQLCODE);
		DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE : ' || SQLERRM);
    
END;
/

;

create or replace function FN_CM_GET_APPROVAL_AGENT_ID
( I_TENANT_ID   IN VARCHAR2
 ,I_APPROVAL_ID IN VARCHAR2
 ,I_RETURN      IN VARCHAR2 /* SNO OR AGENT */
)
RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       FN_CM_GET_APPROVAL_AGENT_ID
   PURPOSE:    결재상태(APPROVAL_STATUS) 에 따라  최종결재자ID(SNO) 또는 결재예정자ID(SNO)를 리턴

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/02/22  YAKIM
******************************************************************************/
	V_APPROVAL_STATUS   VARCHAR2(50) :='';
	V_APPROVAL_AGENT_ID VARCHAR2(50) :='';
	
BEGIN

-- ********************************************************************************
-- 0.결재상태 조회
-- ********************************************************************************    
	  SELECT A.APPROVAL_STATUS INTO V_APPROVAL_STATUS
	   FROM TB_CM_APPROVAL_HEADER A
	  WHERE A.TENANT_ID    =  I_TENANT_ID 
	    AND A.APPROVAL_ID  =  I_APPROVAL_ID ;
	    
-- ********************************************************************************
-- 1.결재상태에 따라 결재자 조회
-- ********************************************************************************  	    
	    IF (V_APPROVAL_STATUS ='00') THEN  
	        V_APPROVAL_AGENT_ID :='';
	   
	    /* 상신(10) 또는 진행(20) 이면  첫번째 결재자 >>결재코드 공백인 첫번째 결재자*/   
	    ELSIF (V_APPROVAL_STATUS ='10' OR V_APPROVAL_STATUS ='20') THEN
	       SELECT A.APPROVAL_AGENT_ID INTO V_APPROVAL_AGENT_ID
	         FROM (
			       SELECT (CASE WHEN I_RETURN ='SNO' THEN TO_CHAR(A.SNO) ELSE A.APPROVAL_AGENT_ID END ) AS APPROVAL_AGENT_ID
			             ,ROW_NUMBER() OVER(ORDER BY SNO ASC ) AS RN
			         FROM TB_CM_APPROVAL_DETAIL A
			        WHERE A.TENANT_ID    =  I_TENANT_ID 
			          AND A.APPROVAL_ID  =  I_APPROVAL_ID
			          AND A.APPROVAL_CODE IS NULL
			        ) A
			  WHERE RN = 1;
	   
	  /* 반려(30) 또는 종결(40) / 종결(전결) 50 이면  최종결재자 구함 >> 결재코드 값 존재하는 마지막 결재자*/   
	    ELSIF (V_APPROVAL_STATUS ='30' OR V_APPROVAL_STATUS ='40' OR V_APPROVAL_STATUS ='50') THEN
	       SELECT A.APPROVAL_AGENT_ID INTO V_APPROVAL_AGENT_ID
	         FROM (
			       SELECT (CASE WHEN I_RETURN ='SNO' THEN TO_CHAR(A.SNO) ELSE A.APPROVAL_AGENT_ID END ) AS APPROVAL_AGENT_ID
			             ,ROW_NUMBER() OVER(ORDER BY SNO DESC ) AS RN
			         FROM TB_CM_APPROVAL_DETAIL A
			        WHERE A.TENANT_ID    =  I_TENANT_ID 
			          AND A.APPROVAL_ID  =  I_APPROVAL_ID
			          AND A.APPROVAL_CODE IS NOT NULL
			        ) A
			  WHERE RN = 1;       
	   END IF;
  
  RETURN V_APPROVAL_AGENT_ID;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
	    V_APPROVAL_AGENT_ID := null;
	    RETURN V_APPROVAL_AGENT_ID;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
END;
/

;

create or replace FUNCTION FN_CM_GET_BUSINESS_DAY
(
   I_TENANT_ID  IN VARCHAR2
   ,I_FROM_YMD  IN VARCHAR2
   ,I_TO_YMD	IN VARCHAR2
 
)
RETURN VARCHAR2
IS
/******************************************************************************
   NAME:       FN_CM_GET_BUSINESS_DAY
   PURPOSE:    상담자명(사번) 형태로 리턴

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/01/20  YAKIM
******************************************************************************/
  V_RLT VARCHAR2(120):='' ;

BEGIN

	SELECT COUNT(STD_YMD) INTO V_RLT
	FROM TB_CM_HOLIDAY 
	WHERE TENANT_ID = I_TENANT_ID
	AND STD_YMD BETWEEN I_FROM_YMD AND I_TO_YMD
	AND HOLI_YN = '0';

  RETURN V_RLT;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
    V_RLT := null;
    RETURN V_RLT;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);    
END;
/

;

CREATE OR REPLACE FUNCTION FN_CM_GET_CODE_NM
(
	I_TENANT_ID  IN VARCHAR2
	,I_SORT_CD   IN VARCHAR2
	,I_CODE      IN VARCHAR2
)
RETURN VARCHAR2
IS
  
  VS_CODE_NM  VARCHAR2(100):='' ;

/*
tb_code 테이블에서 sort_cd, code로 code이름을 찾는다.
SELECT FN_CM_GET_CODE_NM('BT','AGENT_JIKGUP','10') FROM DUAL;

*/
BEGIN
  
  VS_CODE_NM := '';
  
  SELECT NVL(CODE_NM, '')
  INTO VS_CODE_NM
  FROM TB_CM_CODE
  WHERE TENANT_ID = I_TENANT_ID
    AND SORT_CD   = I_SORT_CD
    AND CODE      = I_CODE;
  
  RETURN VS_CODE_NM;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
    VS_CODE_NM := '';
    RETURN VS_CODE_NM;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('오류발생.');
    DBMS_OUTPUT.PUT_LINE('SQL ERROR CODE : ' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE : ' || SQLERRM);
    --DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    
END;
/

;

create or replace function FN_CM_GET_DEPT_ACCESS_SCOPE
( I_TENANT_ID    IN VARCHAR2
 ,I_SCOPE_GUBUN  IN VARCHAR2
 ,I_ITEM_ID	     IN VARCHAR2
 ,I_RETURN       IN VARCHAR2 /* ID OR NM */
)
RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       FN_CM_GET_DEPT_ACCESS_SCOPE
   PURPOSE:    관리소속 DEPT ID 또는 DEPT NM 을 콤마로 열결하여 리턴 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/03/03  YAKIM
******************************************************************************/
	V_RLT VARCHAR2(1000) :='';
	
BEGIN

-- ********************************************************************************
-- 0.관리소속 조회
-- ********************************************************************************    
	IF (I_RETURN ='ID') THEN
		SELECT WM_CONCAT(S.DEPT_CD)  
		  INTO V_RLT
		  FROM TB_CM_ACCESS_SCOPE S
	    WHERE TENANT_ID   = I_TENANT_ID 
	      AND SCOPE_GUBUN = I_SCOPE_GUBUN
	      AND ITEM_ID     = I_ITEM_ID  ;
	ELSE
	SELECT WM_CONCAT(T.DEPT_NM)   INTO V_RLT
		  FROM TB_CM_ACCESS_SCOPE S 
		  INNER JOIN TB_CM_DEPT_CD T ON (S.TENANT_ID = T.TENANT_ID AND S.DEPT_CD = T.DEPT_CD )
		  WHERE S.TENANT_ID   = I_TENANT_ID 
	      AND S.SCOPE_GUBUN = I_SCOPE_GUBUN
	      AND S.ITEM_ID     = I_ITEM_ID  ; 
	/*
		SELECT AGGR_CONCAT( FN_CM_GET_DEPT_NM( S.TENANT_ID,'jo', S.DEPT_CD), ',') 
		  INTO V_RLT
		  FROM TB_CM_ACCESS_SCOPE S
	    WHERE TENANT_ID   = I_TENANT_ID 
	      AND SCOPE_GUBUN = I_SCOPE_GUBUN
	      AND ITEM_ID     = I_ITEM_ID  ;
	      */
	END IF;
  
  IF V_RLT IS NULL THEN 
     V_RLT :='' ;
  END IF;   
  RETURN V_RLT;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
	    V_RLT := null;
	    RETURN V_RLT;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
END;
/

;

create or replace function fn_cm_get_dept_cd
( I_TENANT_ID  IN VARCHAR2
 , ps_gubun in varchar2, --'center', 'part', 'team', 'jo'
  ps_dept_cd in varchar2
)
return varchar2
is
   
  vs_parent_dept_cd        VARCHAR2(20):='' ;
  vn_dept_depth            NUMBER:='' ;
  vs_dept_nm               VARCHAR2(20):='' ;
  vs_dept_cd               VARCHAR2(20):='' ;
  
/*
센터 - 파트 - 팀 - 조

dept_cd 로 '센터 - 파트 - 팀 - 조' 소속코드를 찾는다.
select  dept_cd,
        dept_nm,
        fn_cm_get_dept_cd('BT', 'center', dept_cd) as center,
        fn_cm_get_dept_cd('BT', 'part', dept_cd) as part,
        fn_cm_get_dept_cd('BT', 'team', dept_cd) as team,
        fn_cm_get_dept_cd('BT', 'jo', dept_cd) as jo
from tb_cm_dept_cd;

*/
BEGIN
  
  
  select dept_cd, dept_nm, dept_depth, parent_dept_cd
  into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
  from tb_cm_dept_cd
  where  TENANT_ID = I_TENANT_ID
    AND dept_cd = ps_dept_cd;
  
  case lower(ps_gubun)
    when 'center' then
      while vn_dept_depth > 0
      loop
        select dept_cd, dept_nm, dept_depth, parent_dept_cd
        into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
        from tb_cm_dept_cd
        where  TENANT_ID = I_TENANT_ID
            AND dept_cd = vs_parent_dept_cd;
      
      end loop;
      
    when 'part' then
      if vn_dept_depth < 1 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 1
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd
          where TENANT_ID = I_TENANT_ID
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'team' then
      if vn_dept_depth < 2 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 2
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd
          where TENANT_ID = I_TENANT_ID
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'jo' then
      if vn_dept_depth < 3 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 3
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd
          where TENANT_ID = I_TENANT_ID
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
  end case;
  
  
  
  return vs_dept_cd;
  
  exception when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
    return ps_dept_cd;
end;
/

;

create or replace function fn_cm_get_dept_cd_history
(
  I_TENANT_ID  IN VARCHAR2,
  ps_gubun in varchar2, --'center', 'part', 'team', 'jo'
  ps_std_month in varchar2,
  ps_dept_cd in varchar2
)
return varchar2
is
   
  vs_parent_dept_cd        VARCHAR2(20):='' ;
  vn_dept_depth            NUMBER:='' ;
  vs_dept_nm               VARCHAR2(20):='' ;
  vs_dept_cd               VARCHAR2(20):='' ;

/*
센터 - 파트 - 팀 - 조

소속 이력 테이블에서 dept_cd 로 '센터 - 파트 - 팀 - 조' 소속코드를 찾는다.
select  dept_cd,
        dept_nm,
        fn_cm_get_dept_cd_history('BT', 'center', '201702', dept_cd) as center,
        fn_cm_get_dept_cd_history('BT', 'part', '201702', dept_cd) as part,
        fn_cm_get_dept_cd_history('BT', 'team', '201702', dept_cd) as team,
        fn_cm_get_dept_cd_history('BT', 'jo', '201702', dept_cd) as jo
from tb_cm_dept_cd_history
where std_month = '201702';

*/
BEGIN
  
  
  select dept_cd, dept_nm, dept_depth, parent_dept_cd
  into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
  from TB_CM_DEPT_CD_HISTORY
  where TENANT_ID = I_TENANT_ID
  	and STD_MONTH = ps_std_month
    and dept_cd = ps_dept_cd;
    
  
  
  case lower(ps_gubun)
    when 'center' then
      while vn_dept_depth > 0
      loop
        select dept_cd, dept_nm, dept_depth, parent_dept_cd
        into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
        from TB_CM_DEPT_CD_HISTORY
        where TENANT_ID = I_TENANT_ID
          and STD_MONTH = ps_std_month
          and dept_cd = vs_parent_dept_cd;
      
      end loop;
      
    when 'part' then
      if vn_dept_depth < 1 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 1
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from TB_CM_DEPT_CD_HISTORY
          where TENANT_ID = I_TENANT_ID
            and STD_MONTH = ps_std_month
            and dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'team' then
      if vn_dept_depth < 2 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 2
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from TB_CM_DEPT_CD_HISTORY
          where TENANT_ID = I_TENANT_ID
            and STD_MONTH = ps_std_month
            and dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'jo' then
      if vn_dept_depth < 3 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 3
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from TB_CM_DEPT_CD_HISTORY
          where TENANT_ID = I_TENANT_ID
            and STD_MONTH = ps_std_month
            and dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
  end case;
  
  
  
  return vs_dept_cd;
  
  exception when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
    
end;
/

;

create or replace function fn_cm_get_dept_cd_history_BAK20170313
(
  ps_gubun in varchar2, --'center', 'part', 'team', 'jo'
  ps_std_month in varchar2,
  ps_dept_cd in varchar2
)
return varchar2
is
   
  vs_parent_dept_cd        VARCHAR2(20):='' ;
  vn_dept_depth            NUMBER:='' ;
  vs_dept_nm               VARCHAR2(20):='' ;
  vs_dept_cd               VARCHAR2(20):='' ;

/*
센터 - 파트 - 팀 - 조

소속 이력 테이블에서 dept_cd 로 '센터 - 파트 - 팀 - 조' 소속코드를 찾는다.
select  dept_cd,
        dept_nm,
        fn_cm_get_dept_cd_history('center', '201605', dept_cd) as center,
        fn_cm_get_dept_cd_history('part', '201605', dept_cd) as part,
        fn_cm_get_dept_cd_history('team', '201605', dept_cd) as team,
        fn_cm_get_dept_cd_history('jo', '201605', dept_cd) as jo
from tb_cm_dept_cd_history;

*/
BEGIN
  
  
  select dept_cd, dept_nm, dept_depth, parent_dept_cd
  into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
  from TB_CM_DEPT_CD_HISTORY
  where STD_MONTH = ps_std_month
    and dept_cd = ps_dept_cd;
  
  case lower(ps_gubun)
    when 'center' then
      while vn_dept_depth > 0
      loop
        select dept_cd, dept_nm, dept_depth, parent_dept_cd
        into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
        from TB_CM_DEPT_CD_HISTORY
        where STD_MONTH = ps_std_month
          and dept_cd = vs_parent_dept_cd;
      
      end loop;
      
    when 'part' then
      if vn_dept_depth < 1 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 1
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from TB_CM_DEPT_CD_HISTORY
          where STD_MONTH = ps_std_month
            and dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'team' then
      if vn_dept_depth < 2 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 2
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from TB_CM_DEPT_CD_HISTORY
          where STD_MONTH = ps_std_month
            and dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'jo' then
      if vn_dept_depth < 3 then
        vs_dept_cd := '';
      else
        while vn_dept_depth > 3
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from TB_CM_DEPT_CD_HISTORY
          where STD_MONTH = ps_std_month
            and dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
  end case;
  
  
  
  return vs_dept_cd;
  
  exception when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
    
end;
/

;

create or replace function fn_cm_get_dept_nm
(
  I_TENANT_ID    IN VARCHAR2,
  ps_gubun in varchar2, --'center', 'part', 'team', 'jo'
  ps_dept_cd in varchar2
)
return varchar2
is
   
  vs_dept_cd               VARCHAR2(20) := '';
  vs_parent_dept_cd        VARCHAR2(20) := '';
  vn_dept_depth            NUMBER := '';
  vs_dept_nm               VARCHAR2(120) := '';

/*
센터 - 파트 - 팀 - 조

dept_cd 로 '센터 - 파트 - 팀 - 조 '소속 이름을 찾는다.
select  dept_cd,
        dept_nm,
        fn_cm_get_dept_nm('BT', 'center',  dept_cd) as center,
        fn_cm_get_dept_nm('BT', 'part',  dept_cd) as part,
        fn_cm_get_dept_nm('BT', 'team', dept_cd) as team,
        fn_cm_get_dept_nm('BT', 'jo',  dept_cd) as jo
from tb_cm_dept_cd;

*/
BEGIN
  
  select dept_cd, dept_nm, dept_depth, parent_dept_cd
  into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
  from tb_cm_dept_cd
  where TENANT_ID = I_TENANT_ID
    AND dept_cd = ps_dept_cd;
  
  case lower(ps_gubun)
    when 'center' then
      while vn_dept_depth > 0
      loop
        select dept_cd, dept_nm, dept_depth, parent_dept_cd
        into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
        from tb_cm_dept_cd
        where TENANT_ID = I_TENANT_ID
          AND dept_cd = vs_parent_dept_cd;
      
      end loop;
      
    when 'part' then
      if vn_dept_depth < 1 then
        vs_dept_nm := '';
      else
        while vn_dept_depth > 1
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd
          where TENANT_ID = I_TENANT_ID
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'team' then
      if vn_dept_depth < 2 then
        vs_dept_nm := '';
      else
        while vn_dept_depth > 2
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd
          where TENANT_ID = I_TENANT_ID
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'jo' then
      if vn_dept_depth < 3 then
        vs_dept_nm := '';
      else
        while vn_dept_depth > 3
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd
          where TENANT_ID = I_TENANT_ID
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
  end case;
  
  
  
  return vs_dept_nm;
  
  exception when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
    
    -- 2016/10/26 ADD JHMO
    return '';
    
end;
/

;

create or replace function fn_cm_get_dept_nm_history
(
  I_TENANT_ID    IN VARCHAR2,
  ps_gubun in varchar2, --'center', 'part', 'team', 'jo'
  ps_std_month in varchar2,
  ps_dept_cd in varchar2
)
return varchar2
is
   
  vs_dept_cd               VARCHAR2(20) := '';
  vs_parent_dept_cd        VARCHAR2(20) := '';
  vn_dept_depth            NUMBER := '';
  vs_dept_nm               VARCHAR2(120) := '';

/*
센터 - 파트 - 팀 - 조

dept_cd 로 '센터 - 파트 - 팀 - 조 '소속 이름을 찾는다.
select  dept_cd,
        dept_nm,
        fn_cm_get_dept_nm('BT', 'center', '201702', dept_cd) as center,
        fn_cm_get_dept_nm('BT', 'part', '201702', dept_cd) as part,
        fn_cm_get_dept_nm('BT', 'team', '201702', dept_cd) as team,
        fn_cm_get_dept_nm('BT', 'jo', '201702', dept_cd) as jo
from tb_cm_dept_cd_history
where std_month = '201702';

*/
BEGIN
  
  select dept_cd, dept_nm, dept_depth, parent_dept_cd
  into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
  from tb_cm_dept_cd_history
  where TENANT_ID = I_TENANT_ID
    and std_month = ps_std_month
    AND dept_cd = ps_dept_cd;
  
  case lower(ps_gubun)
    when 'center' then
      while vn_dept_depth > 0
      loop
        select dept_cd, dept_nm, dept_depth, parent_dept_cd
        into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
        from tb_cm_dept_cd_history
        where TENANT_ID = I_TENANT_ID
          and std_month = ps_std_month
          AND dept_cd = vs_parent_dept_cd;
      
      end loop;
      
    when 'part' then
      if vn_dept_depth < 1 then
        vs_dept_nm := '';
      else
        while vn_dept_depth > 1
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd_history
          where TENANT_ID = I_TENANT_ID
            and std_month = ps_std_month
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'team' then
      if vn_dept_depth < 2 then
        vs_dept_nm := '';
      else
        while vn_dept_depth > 2
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd_history
          where TENANT_ID = I_TENANT_ID
            and std_month = ps_std_month
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
      
    when 'jo' then
      if vn_dept_depth < 3 then
        vs_dept_nm := '';
      else
        while vn_dept_depth > 3
        loop
          select dept_cd, dept_nm, dept_depth, parent_dept_cd
          into vs_dept_cd, vs_dept_nm, vn_dept_depth, vs_parent_dept_cd
          from tb_cm_dept_cd_history
          where TENANT_ID = I_TENANT_ID
            and std_month = ps_std_month
            AND dept_cd = vs_parent_dept_cd;
        
        end loop;
      end if;
      
  end case;
  
  
  
  return vs_dept_nm;
  
  exception when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
    
    -- 2016/10/26 ADD JHMO
    return '';
    
end;
/

;

create or replace function FN_CM_GET_SECONDS_TO_FORMAT
( I_SECONDES    IN NUMBER  /* SECODENS */ 
)
RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       FN_CM_GET_SECONDS_TO_FORMAT
   PURPOSE:    초를 HH:MI:SS 포맷으로 리턴
   e.g) SELECT FN_CM_GET_SECONDS_TO_FORMAT(60) AS AA FROM DUAL ; --'00:01:00'
        SELECT FN_CM_GET_SECONDS_TO_FORMAT(28800) AS AA FROM DUAL ; --'08:00:00'
        
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/04/14  YAKIM
******************************************************************************/
	V_RETURN VARCHAR2(10) :='';

	V_HOUR   VARCHAR2(4) :='';
	V_MIN    VARCHAR2(2) :='';
	V_SECOND VARCHAR2(2) :='';
	
BEGIN

-- ********************************************************************************
-- 1. 초를 시분로초
-- ******************************************************************************** 
     SELECT FLOOR(DIFF_SS/(60*60))  AS HOUR
	      ,LPAD(FLOOR (MOD( (DIFF_SS/60 ), 60) ), 2, 0)  AS MIN
	      ,LPAD(FLOOR (MOD(  DIFF_SS, 60) ), 2, 0)  AS SECOND
	       INTO V_HOUR,  V_MIN,V_SECOND
	 FROM (
	      SELECT NVL(I_SECONDES,0) AS DIFF_SS FROM DUAL
	   ) ;     
	   
     IF V_HOUR < 10 THEN  
        V_HOUR := '0'||V_HOUR ;
      END IF;
             
     V_RETURN := V_HOUR||':'||V_MIN ||':'||  V_SECOND ;
 
  RETURN V_RETURN;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
	     RETURN V_RETURN;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    RETURN V_RETURN;
END;
/

;

create or replace function FN_CM_GET_TIME_DIFF_TO_HHMI
( 
   I_NEXT_DAY    IN NUMBER
 , I_FROM_TIME   IN VARCHAR2 /* HH24MI */
 , I_TO_TIME     IN VARCHAR2 /* HH24MI */
)
RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       FN_CM_GET_TIME_DIFF_TO_HHMI
   PURPOSE:    두 시간 간 차이를 계산하여 HHMI 로 리턴하는데 하루이상의 시간차를 구해야하는 경우 사용
   e.g) SELECT FN_CM_GET_TIME_DIFF_TO_HHMI('1','1800','0600') AS AA FROM DUAL ;
   
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/3/3
******************************************************************************/
	V_RETURN VARCHAR2(8) :='';
	V_FROM VARCHAR2(6) :=I_FROM_TIME;
	V_TO   VARCHAR2(6) :=I_TO_TIME;
	
	V_DAY   VARCHAR2(100) :='';
	V_HOUR   VARCHAR2(2) :='';
	V_MIN    VARCHAR2(2) :='';
	
BEGIN

-- ********************************************************************************
-- 1. 두 시간간 차이 계산
-- ******************************************************************************** 
   IF(V_FROM IS NOT NULL AND V_TO IS NOT NULL) THEN
   	
	   	SELECT  
	   	        TO_NUMBER (SUBSTR (TIME_DIFF, 2, 9)) day
		       , LPAD(SUBSTR (TIME_DIFF, 12, 2),2,'0') hour
		       , LPAD(SUBSTR (TIME_DIFF, 15, 2),2,'0') minute
		       INTO V_DAY, V_HOUR,  V_MIN
	    FROM (SELECT NUMTODSINTERVAL (TO_DATE(TO_CHAR(TO_DATE('20170101','YYYYMMDD')+I_NEXT_DAY, 'YYYYMMDD')||TO_TIME, 'YYYYMMDDHH24MI') 
	    								- TO_DATE('20170101'||FROM_TIME, 'YYYYMMDDHH24MI'), 'DAY') AS TIME_DIFF
	             FROM (SELECT V_FROM AS FROM_TIME
	                        , V_TO   AS TO_TIME
	                     FROM DUAL));
	   	
		IF(V_DAY > 0) THEN
	   	
	   		V_HOUR := V_HOUR+V_DAY*24;
	   		
	   	END IF;
   	
    V_RETURN := V_HOUR||V_MIN;
         
   END IF;
   
  RETURN V_RETURN;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
	     RETURN V_RETURN;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    RETURN V_RETURN;
END;
/

;

create or replace function FN_CM_GET_TIME_DIFF_TO_SECOND
( I_FROM_TIME   IN VARCHAR2 /* HH24MISS OR YYYYMMDDHH24MISS */
 ,I_TO_TIME     IN VARCHAR2 /* HH24MISS OR YYYYMMDDHH24MISS */
)
RETURN NUMBER IS
/******************************************************************************
   NAME:       FN_CM_GET_TIME_DIFF_TO_SECOND
   PURPOSE:    두 시간 간 차이를 초로 계산하여 리턴
   e.g) SELECT FN_CM_GET_TIME_DIFF_TO_SECOND('090000','103100') AS AA FROM DUAL ; 
        SELECT FN_CM_GET_TIME_DIFF_TO_SECOND('20170321103000','20170321130000') AS AA FROM DUAL ; 
   
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/02/23  YAKIM
******************************************************************************/
	V_RETURN NUMBER(10) :=0;
	V_FROM VARCHAR2(14) :=I_FROM_TIME;
	V_TO   VARCHAR2(14) :=I_TO_TIME;
	
BEGIN

-- ********************************************************************************
-- 0. 길이체크 4자리이면 00초로
-- ********************************************************************************
	IF(LENGTH(V_FROM)=4) THEN V_FROM := V_FROM||'00' ; END IF;
	IF(LENGTH(V_TO)=4)   THEN V_TO   := V_TO||'00'   ; END IF;

-- ********************************************************************************
-- 1. 두 시간간 차이 계산
-- ******************************************************************************** 
   IF(V_FROM IS NOT NULL AND V_TO IS NOT NULL) THEN
		IF(LENGTH(V_FROM)= 6 AND LENGTH(V_TO)= 6 ) THEN
   		V_RETURN := ROUND((TO_DATE(V_TO ,'HH24MISS')-TO_DATE(V_FROM,'HH24MISS'))*24*60*60) ;
   		ELSIF(LENGTH(V_FROM)= 14 AND LENGTH(V_TO)= 14 ) THEN
   		V_RETURN := ROUND((TO_DATE(V_TO ,'YYYYMMDDHH24MISS')-TO_DATE(V_FROM,'YYYYMMDDHH24MISS'))*24*60*60) ;
   		END IF;
   END IF;
   
  RETURN V_RETURN;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
	     RETURN V_RETURN;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    RETURN V_RETURN;
END;
/

;

create or replace function FN_CM_GET_TIME_FORMAT
( I_SECOND IN NUMBER
)
RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       FN_CM_GET_TIME_FORMAT
   PURPOSE:   초를 시 분 초로 변환

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/02/23  
******************************************************************************/
	V_RETURN VARCHAR2(10) :='';

	
BEGIN

-- ********************************************************************************
-- 시분초로 치환
-- ********************************************************************************   

	V_RETURN :=    TRUNC(I_SECOND/(60*60))         ||':'||
			       LPAD(TRUNC(MOD((I_SECOND/60),60)),2,0)||':'||
			       LPAD(TRUNC(MOD(I_SECOND,60)),2,0)   ;

  RETURN V_RETURN;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
	     RETURN V_RETURN;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    RETURN V_RETURN;
END;
/

;

CREATE OR REPLACE FUNCTION FN_CM_GET_WORKPERIOD
(
 I_KIND                 VARCHAR2      --산출표기구분  M :00년 00개월 / D: 00일(00년00개월)
,I_FROM_DT              VARCHAR2      -- 시작일자
,I_TO_DT                VARCHAR2      --종료일자

 ) RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       FN_CM_GET_WORKPERIOD
   PURPOSE:    근속기간 산출

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
    1.0       2017/02/14  YAKIM
******************************************************************************/
 V_RLT VARCHAR2(120):='' ;
 V_YY  VARCHAR2(10) :='' ;
 V_MM  VARCHAR2(10) :='' ;
 V_DD  VARCHAR2(10) :='' ;
 V_FULLDD  VARCHAR2(10) :='' ; 
 V_TO_DT VARCHAR2(8) :='' ;
BEGIN

	IF (I_TO_DT IS NULL OR I_TO_DT = '') THEN
		V_TO_DT := TO_CHAR(SYSDATE,'YYYYMMDD');
	ELSE
		V_TO_DT := I_TO_DT;
	END IF;

	SELECT FLOOR(STD_MM/12) YYS 
		  , MOD(STD_MM,12) MMS 
		  , TRUNC(TO_DATE(V_TO_DT,'YYYYMMDD'),'dd') - ADD_MONTHS(STD_DT,STD_MM) AS DAYS 
		  , TRUNC(TO_DATE(V_TO_DT,'YYYYMMDD') - STD_DT) AS FULL_DAYS
		  INTO V_YY, V_MM, V_DD, V_FULLDD
	FROM ( 
		SELECT STD_DT 
		     , FLOOR(MONTHS_BETWEEN(TO_DATE(V_TO_DT,'YYYYMMDD'),STD_DT))AS STD_MM
		FROM (SELECT TO_DATE(I_FROM_DT,'YYYYMMDD') AS STD_DT FROM DUAL) 
		) ;
				
	  IF    I_KIND = 'M' THEN
	  		IF (I_FROM_DT IS NULL OR I_FROM_DT = '') THEN
	  		    V_RLT := '0년 0개월' ;
	  		ELSE
	            V_RLT := V_YY||'년 ' ||V_MM ||'개월' ;        
	        END IF;
	        
	  ELSIF I_KIND = 'D' THEN
	  	    IF I_FROM_DT IS NULL OR I_FROM_DT = '' THEN
	  		    V_RLT := '0일(0년 0개월)' ;
	  		ELSE
	  		    V_RLT := TRIM(TO_CHAR(V_FULLDD, '999,999'))||' 일 ('||V_YY||'년 ' ||V_MM ||'개월)' ;       
	        END IF;
	 END IF;
 
  RETURN V_RLT;
  
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
    V_RLT := null;
    RETURN V_RLT;
  WHEN OTHERS THEN 
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
END;
/

;

create or replace function fn_cm_string_format
(
  is_data in varchar2,
  is_format in varchar2
)
return varchar2
is

vn_data_offset number;
vn_loop_count number;
vs_format_string varchar2(255);


begin

vn_loop_count := length(is_format);
vs_format_string := '';
vn_data_offset := 1;



  
  if is_data is null then
    vs_format_string := '';
  else 
    while vn_loop_count > 0
    loop
      if substr(is_format, length(is_format) - vn_loop_count + 1, 1) = '@' then
        vs_format_string := vs_format_string || substr(is_data, vn_data_offset, 1);
        vn_data_offset := vn_data_offset + 1;
      else
        vs_format_string := vs_format_string || substr(is_format, length(is_format) - vn_loop_count + 1, 1);
      end if;
      
      vn_loop_count := vn_loop_count - 1;
    end loop;
  end if;
  

return NVL(vs_format_string,'');

exception when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);

end;
/

;

create or replace function fn_cm_string_format_money
(
  is_data in number,
  is_decimal_point_yn in varchar2 := 'n' --소수점 표시 여부
)
return varchar2
is

vs_format_string varchar2(255);

/*
숫자 -> money 포맷으로 변환한다. 
select FN_CM_STRING_FORMAT_MONEY(1234.56, 'n') from dual; -> 1,235
select FN_CM_STRING_FORMAT_MONEY(1234.56, 'y') from dual; -> 1,234.56

*/

begin

if lower(is_decimal_point_yn) = 'n' then
  vs_format_string := to_char(is_data, '999,999,999,999');
else
  vs_format_string := to_char(is_data, '999,999,999,999.99');
end if;



return vs_format_string;

exception when others then
    dbms_output.put_line('오류발생.');
    dbms_output.put_line('sql error code : ' || sqlcode);
    dbms_output.put_line('sql error message : ' || SQLERRM);
    --dbms_output.put_line(dbms_utility.format_error_backtrace);

end;
/

;
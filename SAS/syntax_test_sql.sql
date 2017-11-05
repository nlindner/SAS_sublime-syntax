-- SYNTAX TEST "Packages/Enhanced-TSQL/Enhanced-TSQL.sublime-syntax"

SELECT 'Foo '' Bar';
--           ^ constant.character.escape.sql

SELECT "My "" Crazy Column Name" FROM my_table;
--         ^ constant.character.escape.sql

SELECT 
(
SELECT CASE field
    WHEN 1
    THEN -- comment's say that
--                    ^ comment.line.double-dash
        EXISTS(
        select 1)
    ELSE NULL
    end
) as result;


/*
This is a
multiline comment
-- ^ source.sql comment.block.sql
*/

/* NLINDNER additions */

SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON 
SET ANSI_NULLS ON
--  ^ all should be colored
go

CREATE TABLE dbo.Complaint (
   [ComplaintID] [int] IDENTITY(1,1) NOT NULL
--                ^ should be captured
   ,[DateAdded] [datetime] NULL 
--   ^ support.function.datetime.sql should not capture
   ,[ClaimYear0Pct] [FLOAT] NULL
--                   ^ this datatype keyword (and datetime for DateAdded) should be captured
   ,CONSTRAINT PK_Complaint PRIMARY KEY (
      ComplaintId
   )
)  


IF OBJECT_ID('tempdb..#tempComplaints') IS NULL
IF OBJECT_ID('tempdb..#tempComplaints') IS NOT NULL
IF OBJECT_ID('tempdb..##tempComplaints') IS NOT NULL
IF OBJECT_ID('tempdb..##tempComplaints123') IS NOT NULL
--                                      ^ both should be captured
select *
from #tempcomplaints

select *
from ##tempcomplaints

select *
from #tempcomplaints2


SELECT 
    DATEADD(DAY, 1-DATEPART(WEEKDAY, getDate())) AS My_Dt
   ,DATEPART(WEEKDAY, getDate()) as nml
FROM dbo.DIM_Date

SET @cmd = 'DIR /b "' + @backupPath + '"' + '''extra text''' + 'extra text'
INSERT INTO @fileList(backupFile) 
-- embedded quotes should end


/* SEE https://msdn.microsoft.com/en-us/library/ms178623.aspx */
DECLARE @comment AS varchar(20);  
GO  
/*  
SELECT @comment = '';   
*/ 
  

SELECT @@VERSION;  
GO   

create procedure [dbo].blah as
BEGIN
   UPDATE MQ SET
      LM_Value = 'Colonoscopy'
   FROM 
      edw.dbo.Member_Quality MQ
      JOIN (
         SELECT patientID, lab_date, value from member_emr_labs_data emr WHERE Lab_Name = 'Colonoscopy'
      ) A on a.patientID = mq.patientID

END
GO

  

      if object_id('TEMPDB..##CRMS_VinInfoExists') is not null 
      BEGIN
         DROP TABLE ##CRMS_VinInfoExists
      END

      CREATE TABLE ##CRMS_VinInfoExists (
          VIN                 [VARCHAR](17) NOT NULL
         ,Vin_Sk              INT         NOT NULL
         ,Mto_Sk              INT         NULL
         ,Upd_Proc_Sk_Vhcl    INT         NULL
         ,Rtl_Sls_Dt          DATETIME    NULL
         ,Af_Off_Dt           DATETIME    NULL
         ,Eng_Off_Dt          DATETIME    NULL
         ,Trmsn_Off_Dt        DATETIME    NULL
         ,RowNum              INT
         ,PRIMARY KEY CLUSTERED ( VIN ) 
      ) ON [PRIMARY]

      CREATE INDEX IX_Temp_VinInfoExists_Vin_Sk
            ON  ##CRMS_VinInfoExists 
                ( Vin_Sk )

       /*** Create temp table with distinct VIN information to be updated in CMQ ***/
      /* row_number after distinct should be unnecessary, but including just in case */
      INSERT INTO ##CRMS_VinInfoExists (
          VIN
         ,Vin_Sk
         ,Mto_Sk
         ,Upd_Proc_Sk_Vhcl
         ,Rtl_Sls_Dt
         ,Af_Off_Dt
         ,Eng_Off_Dt
         ,Trmsn_Off_Dt
         ,RowNum  
      )  
      SELECT 
          VIN
         ,Vin_Sk
         ,Mto_Sk
         ,Upd_Proc_Sk_Vhcl
         ,Rtl_Sls_Dt
         ,Af_Off_Dt
         ,Eng_Off_Dt
         ,Trmsn_Off_Dt
         ,ROW_NUMBER() OVER 
            (  PARTITION BY a.vin ORDER BY a.Upd_proc_sk_vhcl desc ) AS ROWNUM
      FROM (
         SELECT DISTINCT
             Vin
            ,Vin_Sk
            ,Mto_Sk
            ,Upd_Proc_Sk_Vhcl 
            ,Rtl_Sls_Dt
            ,Af_Off_Dt
            ,Eng_Off_Dt
            ,Trmsn_Off_Dt
         FROM 
            dbo.Contact a
         WHERE 
            a.vin IS NOT NULL
            AND a.vin_sk IS NOT NULL
            AND EXISTS (
               SELECT 1 FROM   dbo.Contact b
               WHERE 
                  b.vin IS NOT NULL
                  AND b.vin_sk IS NULL
                  AND b.vin = a.vin
            )
      ) a

       /*** Perm table has Vin_Sk/CMQ info for ONE+ row/case, but other rows only have VIN
         Update the CMQ fields where we can match them with VIN # and set 
         UnixUpdatedVinFlag to 0 if it is 1 ***/
      UPDATE a
      SET
          a.Vin_Sk               = b.Vin_Sk
         ,a.Mto_Sk               = b.Mto_Sk
         ,a.Upd_Proc_Sk_Vhcl     = b.Upd_Proc_Sk_Vhcl
         ,a.Rtl_Sls_Dt           = b.Rtl_Sls_Dt
         ,a.Af_Off_Dt            = b.Af_Off_Dt
         ,a.Eng_Off_Dt           = b.Eng_Off_Dt
         ,a.Trmsn_Off_Dt         = b.Trmsn_Off_Dt
         ,a.UnixUpdatedVinFlag   = 
            CASE WHEN a.UnixUpdatedVinFlag = 1 THEN 0
                 ELSE a.UnixUpdatedVinFlag 
            END
      FROM
         dbo.contact a
          INNER JOIN ##CRMS_VinInfoExists b
            ON  a.VIN = b.VIN
      WHERE 
         a.Vin_Sk IS NULL
         AND a.Vin IS NOT NULL
         AND b.RowNum = 1  



CREATE TABLE dbo.ACS_master AS
SELECT 
    Aug.Vin
   ,aug.AugmentType
   ,CASE
       WHEN aug.AugmentType = 'VINNO' THEN 'I'
       WHEN aug.Upd_Proc_Sk_Vhcl IS NULL 
            OR vSK.Upd_Proc_Sk IS NULL THEN 'HASNULLS'
       WHEN vSK.Upd_Proc_Sk = aug.Upd_Proc_Sk_Vhcl THEN 'N'
       WHEN vSK.Upd_Proc_Sk > aug.Upd_Proc_Sk_Vhcl THEN 'U'
       ELSE 'UNKNOWN' END as Load_Type
   ,CASE 
       WHEN aug.AugmentType = 'VINNO' THEN COALESCE(vNo.Vin_Sk, -1)
       ELSE aug.Vin_Sk
    END AS Vin_Sk
   ,CASE 
       WHEN aug.AugmentType = 'VINNO' THEN COALESCE(vNo.Mto_Sk, -1)
       ELSE COALESCE(vSk.Mto_Sk, aug.Mto_Sk)
    END AS Mto_Sk
   ,coalesce(vSk.Upd_Proc_Sk, vNo.Upd_Proc_Sk, aug.Upd_Proc_Sk_Vhcl) as Upd_Proc_Sk_Vhcl
   ,aug.Upd_Proc_Sk_Vhcl as Upd_Proc_Sk_orig
   ,COALESCE(vSk.Rtl_Sls_Dt, vNo.Rtl_Sls_Dt) AS Rtl_Sls_Dt
   ,COALESCE(vSk.AF_Off_Dt, vNo.AF_Off_Dt) AS AF_Off_Dt
   ,COALESCE(vSk.Eng_Off_Dt, vNo.Eng_Off_Dt) AS Eng_Off_Dt
   ,COALESCE(vSk.Trmsn_Off_Dt, vNo.Trmsn_Off_Dt) AS Trmsn_Off_Dt
FROM 
   dbo.ACS_Augment aug
   LEFT OUTER JOIN dbo.ACSVhclInfo_VinSk vSk
      ON vSk.Vin_Sk = aug.Vin_Sk
   LEFT OUTER JOIN dbo.ACSVhclInfo_VinNo vNo
      ON vNo.Vin_No = aug.Vin




--create function return table , no BEGIN and END in this case
create function Test (
   @TZ int
   ,@ParamName VARCHAR(30)
   ,@ParamName2 VARCHAR(30)
)
returns table
as
return
(
   select   1 AS s FROM dbo.Table1 a
)
GO

create function Test 
   (
   @TZ int
   ,@ParamName VARCHAR(30)
   ,@ParamName2 VARCHAR(30)
)
returns table
as
return
(
   select   1 AS s FROM dbo.Table1
)
GO

--create function return date_type
Create Function dbo.FooBar(
    @p1 nVarchar(4000)
)
Returns int
As
Begin
  return 123;
END
GO

--create function return @val table 
CREATE FUNCTION [dbo].[func1](@String nvarchar(4000))
RETURNS @Bar TABLE (Col1 nvarchar(4000))
AS
   BEGIN

   RETURN
END
GO

--Alter Function, should behave the same as create function, except the ALTER keyword
Alter FUNCTION [dbo].[func1](@String nvarchar(4000))
RETURNS @Bar TABLE (Col1 nvarchar(4000))
AS
   BEGIN

   RETURN
END
GO

--drop Function, you can drop multiple at same time
Drop function Func1 
drop function Func1,Func2, Func3 , Func3



SELECT 
    coalesce(hr.Date, step.Date) AS Date
   ,coalesce(hr.dateTime, step.dateTime) as dateTime
   ,coalesce(hr.time, step.time) as time
   ,hr.confidence AS conf, hr.bpm, hr.defaultZone As hr_zone
   ,step.steps
FROM 
   dHRDetail hr 
   FULL JOIN dStepDetail step
      ON step.Date = hr.Date
      AND step.dateTime = hr.dateTime
   LEFT OUTER JOIN dStepDetail step2
      ON step2.Date = hr.Date
      AND step2.dateTime = hr.dateTime
   JOIN blah blah
      ON blah.a = hr.a
ORDER BY 1, 2


select 
   Claim_Id
   ,DateofServiceFrom as DOS_From_Dt
   ,CASE 
      WHEN 
         HPlan_Sk IN (1, 2, 3, 4) THEN
         CASE WHEN clm.LOB = 'Medicare' THEN 'MA' ELSE 'DUAL' END
      WHEN HPlan_Sk = 5 THEN 'blah'
      WHEN HPlan_Sk = 6 THEN 'MA'
      ELSE 'UNKNOWN'
   END as Src
from 
   dbo.Claim_Header clmH
   INNER JOIN dbo.Claim_Line clmL
      ON clmH.Claim_Head_Id = clmL.Claim_Head_Id
;



CREATE TABLE products
( product_id INT PRIMARY KEY,
  product_name VARCHAR(50) NOT NULL,
  category VARCHAR(25)
);

CREATE TABLE inventory
( inventory_id INT PRIMARY KEY,
  product_id INT NOT NULL,
  quantity INT,
  min_level INT,
  max_level INT 
  constraint blahblah DEFAULT (getdate())
  ,CONSTRAINT fk_inv_product_id FOREIGN KEY (product_id)
    REFERENCES products (product_id)
    ON DELETE CASCADE
);

CREATE TABLE inventory
( inventory_id INT PRIMARY KEY,
  product_id INT NOT NULL,
  quantity INT
  ,CONSTRAINT fk_inv_product_id FOREIGN KEY (
      product_id)
    REFERENCES products (product_id)
    ON DELETE CASCADE
);



CREATE TABLE factory_process
   (event_type   int,
   event_time   datetime,
   event_site   char(50),
   event_desc   char(1024),
CONSTRAINT event_key PRIMARY KEY (event_type, event_time) )
;

ALTER TABLE dbo.Vendors 
ADD CONSTRAINT CK_Vendor_CreditRating  CHECK (CreditRating >= 1 AND CreditRating <= 5)



CREATE PROCEDURE [dbo].[spSearchComplaints]  (   
  @Model VARCHAR(255) = NULL
  ,@Year  VARCHAR(1000) = NULL
  ,@Component VARCHAR(MAX) = NULL
  ,@CrashFlag INT = NULL
  ,@FireFlag INT = NULL
  ,@PoliceRptFlag INT = NULL
  ,@OrigOwnerFlag INT = NULL
  ,@FromDate DateTime = NULL
  ,@ToDate DateTime = NULL
  ,@KeyWords [varchar](500) = NULL
  ,@KeywordsSearchType CHAR(3) = NULL
  ,@ExcldKeyWords VARCHAR(MAX) = NULL
  ,@TechLineCode VARCHAR(1000) = NULL
  ,@BagOfWordsFlag INT = NULL
   --Added below parameter to handle custom grid paging--surendra
  ,@Return_PageNo INT  = NULL OUTPUT
  ,@Return_TotalRecords INT  = NULL OUTPUT
  ,@PageNumber INT=NULL
  ,@RowCount INT=NULL
  ,@SortDirection VARCHAR(100)=NULL
  ,@SortFiledName VARCHAR(200)=NULL
)                   
AS
--SET NOCOUNT ON added to prevent to return no of rows 
SET NOCOUNT ON;

/***************************************                                                      
* Variable Declarations                                                     
***************************************/            
DECLARE @ErrorCode     INT  
DECLARE @WHERE VARCHAR(MAX) 
DECLARE @TempKeyWord VARCHAR(100) 
DECLARE @KeyWordsSql  VARCHAR(MAX)
DECLARE @ExcldKeyWordsSql  VARCHAR(MAX) 
DECLARE @CommaDelimit VARCHAR(1)
DECLARE @MAINSTRING NVARCHAR(MAX) 
DECLARE @SQLPAGINGSORT NVARCHAR(MAX)
DECLARE @SQLEXPORTEXCEL VARCHAR(MAX)
DECLARE @Pos INT 
DECLARE @RowStart VARCHAR(100)
DECLARE @RowEnd VARCHAR(100)
DECLARE @TotalRows INT
      
/***************************************            
Initialize Variables  
***************************************/  
SELECT @ErrorCode  = @@ERROR 
SET @WHERE=''
SET @CommaDelimit = ','
SET @MAINSTRING = ''
SET @SQLPAGINGSORT=''
SET @KeyWordsSql = ''
SET @ExcldKeyWordsSql = ''
SET @TempKeyWord = ''   
 
SELECT @MAINSTRING ='' 

SET @RowEnd = @PageNumber * @RowCount
SET @RowStart =  (@RowEnd) - (@RowCount-1) 

IF OBJECT_ID('tempdb..#tempComplaints') IS NOT NULL
   BEGIN
      DROP TABLE #tempComplaints
   END

set @Pos = @CommaDelimit
CREATE TABLE #tempComplaints (
      ComplaintID INT
      ,[Date] DATETIME
      ,Model VARCHAR(100)
      ,[Year] VARCHAR(10)
      ,VIN VARCHAR(100)
      ,[Component]  VARCHAR(500)
      ,NHTSAReferenceNo INT
      ,ComplaintRate FLOAT
      ,ComplaintText VARCHAR(3000)
      ,Code VARCHAR(100)
      ,Classification VARCHAR(1000)
      ,ARank CHAR(1)
      ,Duplicates CHAr(1)
      ,Notes VARCHAR(MAX)
   )  

IF @KeyWords IS NOT NULL
   BEGIN 
      WHILE (@KeyWords != '')
      BEGIN
         SET @Pos = CHARINDEX(@CommaDelimit, @KeyWords)
         
         IF @Pos <> 0
            BEGIN
               SET @TempKeyWord = SUBSTRING(@KeyWords , 1,@Pos - 1)
               SET @KeyWords = SUBSTRING(@KeyWords, @pos+1,LEN(@KeyWords))
            END
         ELSE
            BEGIN
               SET @TempKeyWord = @KeyWords
               SET @KeyWords = ''
            END            
         SET @KeyWordsSql = 
            CASE 
               WHEN @KeyWordsSql <> '' THEN
                  CASE @KeywordsSearchType 
                     WHEN 'OR' THEN @KeyWordsSql + ' OR (C.CDescr LIKE ' + ''''+'%' + @TempKeyWord  + '%' + '''' + ' OR '+ 'C.CleanCompliantDesc LIKE ' + ''''+'%' + @TempKeyWord  + '%' + ''''+ ')'
                     ELSE  @KeyWordsSql + ' AND (C.CDescr LIKE ' + ''''+'%' + @TempKeyWord  + '%' + '''' + 'OR '+ 'C.CleanCompliantDesc LIKE ' + ''''+'%' + @TempKeyWord  + '%' + ''''+ ')'
                  END
               ELSE @KeyWordsSql + '  (C.CDescr LIKE ' + ''''+'%' + @TempKeyWord  + '%' + '''' + ' OR '+ 'C.CleanCompliantDesc LIKE ' + ''''+'%' + @TempKeyWord  + '%' + ''''+ ')'
            END
      END  
   END
         
IF @ExcldKeyWords IS NOT NULL
   BEGIN 
      WHILE (@ExcldKeyWords != '')
      BEGIN
         SET @Pos = CHARINDEX(@CommaDelimit,@ExcldKeyWords)
         
         IF @Pos <> 0
            BEGIN
               SET @TempKeyWord = SUBSTRING(@ExcldKeyWords,1,@Pos - 1)
               SET @ExcldKeyWords = SUBSTRING(@ExcldKeyWords,@pos+1,LEN(@ExcldKeyWords))
            END
         ELSE
            BEGIN
               SET @TempKeyWord = @ExcldKeyWords
               SET @ExcldKeyWords = ''
            END            
         SET @ExcldKeyWordsSql = 
            CASE 
               WHEN @ExcldKeyWordsSql <> '' THEN @ExcldKeyWordsSql + ' AND C.CDescr NOT LIKE ' + ''''+'%'+ @TempKeyWord + '%' + '''' 
               ELSE @ExcldKeyWordsSql + '  C.CDescr NOT LIKE ' + ''''+'%' + @TempKeyWord + '%' + ''''
            END
      END  
   END         

SELECT @MAINSTRING=
   ' SELECT DISTINCT       
         ComplaintID,
         Days,
         ModelTxt,
         YearTxt,
         VIN,
         CompDesc,
         NHTSAReferenceNo,
         ComplaintRate,
         ComplaintFullText,
         Code,
         Classification,
         ARank,
         Duplicates,
         CurrentNotes
   FROM VComplaintInfo C'
         

IF @Model IS NOT NULL OR @Model <>''
BEGIN    
   SET @WHERE = CASE  WHEN @WHERE <> '' THEN @WHERE + ' AND C.ModelTxt IN ('+''''+ REPLACE(@Model,',',''''+ ','+ '''') + '''' + ')' ELSE  @WHERE + '  C.ModelTxt IN ('+''''+ REPLACE(@Model,',',''''+ ','+ '''') + '''' + ')'  END 
END


IF @Year IS NOT NULL OR   @Year <> ''
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN @WHERE + ' AND C.YearTxt IN ('+''''+ REPLACE(@Year,',',''''+ ','+ '''') + '''' + ')' ELSE  @WHERE + '  C.YearTxt IN ('+''''+ REPLACE(@Year,',',''''+ ','+ '''') + '''' + ')' END
END
 
IF @Component IS NOT NULL OR @Component <> '' 
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND C.CompDesc IN ('+''''+ REPLACE(@Component,',',''''+ ','+ '''') + '''' + ')' ELSE  @WHERE + '  C.CompDesc IN ('+''''+ REPLACE(@Component,',',''''+ ','+ '''') + '''' + ')' END
END

IF @CrashFlag=1 
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND C.CrashFlag  = '+ CAST(@CrashFlag AS VARCHAR(10)) ELSE  @WHERE + '  C.CrashFlag  = '+ CAST(@CrashFlag AS VARCHAR(10))  END
END

IF @FireFlag =1 
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND C.FireFlag  = '+ CAST(@FireFlag AS VARCHAR(10)) ELSE  @WHERE + '  C.FireFlag  = '+  CAST(@FireFlag AS VARCHAR(10))  END
END

IF @PoliceRptFlag =1 
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND C.PoliceRptFlag  = '+ CAST(@PoliceRptFlag AS VARCHAR(10)) ELSE  @WHERE + '  C.PoliceRptFlag  = '+ CAST(@PoliceRptFlag AS VARCHAR(10))  END
END

IF @OrigOwnerFlag =1
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND C.OrigOwnerFlag  = '+ CAST(@OrigOwnerFlag AS VARCHAR(10)) ELSE  @WHERE + '  C.OrigOwnerFlag  = '+ CAST(@OrigOwnerFlag AS VARCHAR(10))  END
END

IF @FromDate IS NOT NULL OR @FromDate <> '' 
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND C.DateAdded >= '+ ''''+ CAST(@FromDate AS VARCHAR(20))+''''   ELSE  @WHERE + '  C.DateAdded  > '+ ''''+ CAST(@FromDate AS VARCHAR(20))+''''   END
END

IF @ToDate IS NOT NULL OR @ToDate<>''
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND C.DateAdded <= '+ ''''+ CAST(@ToDate AS VARCHAR(20))+''''   ELSE  @WHERE + '  C.DateAdded < '+ ''''+ CAST(@ToDate AS VARCHAR(20))+''''   END
END

IF @TechLineCode IS NOT NULL OR @TechLineCode <> '' 
BEGIN      
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE + ' AND (C.Classification LIKE ' + ''''+'%' + @TechLineCode  + '%' + '''' +' OR C.Code LIKE '+ ''''+ @TechLineCode  + '%' + '''' + ')'  ELSE  @WHERE + '  (C.Classification LIKE ' + ''''+'%' + @TechLineCode  + '%' + '''' +'OR C.Code LIKE ' + ''''+ @TechLineCode  + '%' + '''' + ')' END
END



IF @KeyWordsSql <> ''
BEGIN
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE +' AND (' + @KeyWordsSql + ')' ELSE @WHERE +'  (' + @KeyWordsSql + ')' END
END

IF @ExcldKeyWordsSql <> ''
BEGIN
   SET @WHERE= CASE  WHEN @WHERE <> '' THEN  @WHERE +' AND (' + @ExcldKeyWordsSql + ')' ELSE @WHERE +'  (' + @ExcldKeyWordsSql + ')' END
END

  
IF @WHERE <> ' '
   BEGIN  
      SET @WHERE = ' WHERE ' +@WHERE+ ' ORDER BY C.Days'-- Changed the order from C.DateAdded to C.Days as need to get the distinct data and C.dateAdded is not in the select statement---Surendra   
   END
ELSE
   BEGIN  
      SET @WHERE = ' ORDER BY C.Days'-- Changed the order from C.DateAdded to C.Days as need to get the distinct data and C.dateAdded is not in the select statement---Surendra   
   END


--PRINT  @MAINSTRING + @WHERE
INSERT  INTO #tempComplaints 
 EXEC (@MAINSTRING + @WHERE)

IF @BagOfWordsFlag = 1
BEGIN

SELECT 
   TOP 20
   ITEM,
   COUNT 
FROM
   (
      SELECT  
         ComplaintWord AS Item, SUM(WordCount) AS Count 
      FROM dbo.ComplaintWord C 
      INNER JOIN #tempComplaints T ON C.ComplaintID = T.ComplaintID 
      GROUP BY ComplaintWord 
   )P
   ORDER BY COUNT DESC
END
ELSE 
BEGIN
   
   
   IF @PageNumber IS NULL OR @PageNumber=''---fetch whole resultset for export to Excel

      BEGIN
         print 'Export to Excel'
         SET @SQLEXPORTEXCEL='SELECT 
         ComplaintID,
         --[Date] AS [Date],
         CONVERT(VARCHAR(10),[Date],101) AS [Date],
         Model,
         [Year],
         VIN,
         [Component],
         NHTSAReferenceNo,
         ComplaintRate,
         ComplaintText,
         Code AS [Techline Code],
         Classification AS [Techline Desc],
         ARank,
         Duplicates,
         dbo.fnUserPTSNames(ComplaintID) AS UserPTS,
         dbo.fnUserMENames(ComplaintID) AS UserME,
         Notes

      FROM  #tempComplaints ORDER BY '+@SortFiledName+' '+@SortDirection+''

      exec(@SQLEXPORTEXCEL)
      
      END
   ELSE
   BEGIN

   print 'get specified page no record'

   SET @SQLPAGINGSORT='SELECT 
      ComplaintID,
      [Date],
      Model,
      [Year],
      VIN,
      [Component],
      NHTSAReferenceNo,
      ComplaintRate,
      CASE WHEN LEN(ComplaintText) > 50 THEN LEFT(ComplaintText,50) + ''.....'' ELSE ComplaintText END AS ComplaintText,
      Code,
      Classification,
      ARank,
      Duplicates,
      dbo.fnUserPTSNames(ComplaintID) AS UserPTS,
      dbo.fnUserMENames(ComplaintID) AS UserME

   FROM  
   (

   SELECT
      --DENSE_RANK() OVER(ORDER BY ComplaintID) AS RowNo,
      ROW_NUMBER() OVER(ORDER BY '+@SortFiledName+' '+@SortDirection+') AS RowNo,
      ComplaintID,
      CONVERT(VARCHAR(10),[Date],101) AS [Date],
      Model,
      [Year],
      VIN,
      [Component],
      NHTSAReferenceNo,
      ComplaintRate,
      ComplaintText,
      Code,
      Classification,
      ARank,
      Duplicates

   FROM  #tempComplaints
   ) Temp WHERE Temp.RowNo BETWEEN '+@RowStart+' AND  '+@RowEnd+' --ORDER BY [Date]'

   --print @SQLPAGINGSORT
   EXEC(@SQLPAGINGSORT)

   END


SET @TotalRows = (SELECT COUNT(DISTINCT ComplaintID)   FROM #tempComplaints)
IF @TotalRows > 0
BEGIN
   SET @Return_PageNo = CASE WHEN @TotalRows%@RowCount > 0 THEN @TotalRows/@RowCount + 1 ELSE @TotalRows/@RowCount END
   SET @Return_TotalRecords = @TotalRows
--print @Return_TotalRecords
END



IF OBJECT_ID('tempdb..#tempComplaints') IS NOT NULL
   BEGIN
      DROP TABLE #tempComplaints
   END

   
END  
--/************************************                  
--*  Get the Error Message for @@ERROR                 
--*************************************/                  
--IF @ErrorCode <> 0 AND @ErrorCode <> 50001                  
-- BEGIN                  
--                 
--      SELECT @Return_Message = [Description]                   
--      FROM  master.dbo.sysmessages                  
--      WHERE error = @ErrorCode                  
-- END             
--/*******************************                  
--*  RETURN from Stored Procedure                  
--********************************/                  
--RETURN @ErrorCode -- @ErrorCode = 0 if success, @ErrorCode <> 0 if failure             
            
END  

SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
GO
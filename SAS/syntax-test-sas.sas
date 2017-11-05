/* SYNTAX TEST "Packages/SAS/syntaxes/sas.sublime-syntax"; */
/* Here is a comment */
* here is another comment;

* blah blah comment;
%put * test;
/* Known problem:
	Cannot use code like this (with semi-colons for the macro-control-language) within "FROM CONNECTION TO..."
	explicit passthrough. The first semicolon will pop off the embedded SQL context. There is no way around
	this unless I want to make assumptions (that my own code fails to conform to) about how the 
	connection to ...will be closed.
*/
%macro testSQL(sourcetable=dbo.ClaimsHeader, outTableName=resultlist, listColumn=%bquote(Col1 Col2 Col3));

	%local nItem i thisItem;
/* ^^^^^^ source.sas meta.function.macro.sas keyword.other.macro.sas ;	*/

	%let nItem = %NItemInString(&listColumn);
/*              ^ source.sas meta.function.macro.sas punctuation.definition.function.name.macro.sas  */
/*               ^^^^^^^^^^^^^ source.sas meta.function.macro.sas variable.function.name.macro.sas  */
/*                             ^^^^^^^^^^^ variable.other.parameter.sas */
	proc sql;
		%connectToDBMS(DataMart);
		execute (
/*    ^^^^^^^ source.sas meta.function.macro.sas meta.procsql.sas keyword.other.execute.sas-sql  */		
			IF %nrbquote(object_id('tempdb..#&resultlist.')) is not null
/*       ^^ embedded.sql keyword.control.of-flow.sql */
			begin
/*       ^^^^^ embedded.sql meta.block.begin-end.sql keyword.control.block.bgn.sql */
				drop table #&resultlist
/*          ^^^^^^^^^^^^^^^^^^^^^^^ meta.drop.sql */
			end
/*       ^^^^^ embedded.sql meta.block.begin-end.sql keyword.control.block.end.sql */
			%do i = 1 %to &nItem;
				%let thisItem = %scan(&listColumn, &i, %str( ));
				%if &i > 1
				%then %do;
					UNION ALL
				%end;
				SELECT 
					%nrbquote('&thisItem') AS Field_Name
					,len(&thisItem) AS Field_Length
					,count(*) AS Total
					,MIN(&thisItem) AS Field_Min
					,MAX(&thisItem) AS Field_Max
				%if &i = 1
				%then %do;
					INTO #&resultlist
				%end;
				FROM &sourceTable
				GROUP BY 
					len(&thisItem)
			%end;

		) by dataMart;

		create table work.&outTableName AS
		SELECT * FROM CONNECTION TO datamart (
			select *
			from #&outTableName
		);
	quit;


	proc sql;
		%connectToDBMS(DataMart);
		create table work.&outTableName AS
		SELECT * FROM CONNECTION TO datamart (
			IF %nrbquote(object_id('tempdb..#&resultlist.')) is not null
			begin
				drop table #&resultlist
			end
			%do i = 1 %to &nItem;
				%let thisItem = %scan(&listColumn, &i, %str( ));
				%if &i > 1
				%then %do;
					UNION ALL
				%end;
				SELECT 
					%nrbquote('&thisItem') AS Field_Name
					,len(&thisItem) AS Field_Length
					,count(*) AS Total
					,MIN(&thisItem) AS Field_Min
					,MAX(&thisItem) AS Field_Max
				%if &i > 1
				%then %do;
					INTO #&resultlist
				%end;
				FROM &sourceTable
				GROUP BY 
					len(&thisItem)
			%end;
		);
	quit;
%mend;

%testsql;
proc sql;
	* blah blah;
	%put test;
	execute (

			SELECT
				 fMEM.HealthPlan_Id
				,fMEM.Incurred_Month
				,MIN(Some_Date_Field1) AS Some_Date_Field1
				,MAX(Some_Date_Field2) AS Some_Date_Field2
				,SUM(fCLM.IPAdmit_Qty) AS IPAdmit_Qty
				,SUM(fCLM.Claim_Qty) AS Claim_Qty
				,COUNT(DISTINCT CASE 
					WHEN &Is_Nonengaged THEN CAST(NULL AS INT)
					ELSE fMem.Member_Id
				 END) as N_Member
				,MAX(CASE WHEN fClm.Revenue_Code IN (%QuoteList(&Filter_RxCd_Transplant)) THEN 1 ELSE 0 END) AS Has_Transplant
				,'''' + blah + '''' as Test_Field_with_Escaped_Quotes
			FROM 
				&evalTable fCLM
				INNER JOIN dbo.Member_Months fMEM
					ON  fMEM.Member_Id = fCLM.Member_Id 
					AND fMem.Incurred_Month = 
						CONVERT(DATE, DATEADD(day, 1-day(fClm.Claim_Paid_Date), fClm.Claim_Paid_Date))
			WHERE 
				fMEM.Healthplan_id = &Filt_HealthplanId
			GROUP BY 
				 fMEM.HealthPlan_Id
				,fMEM.Incurred_Month
			-- test single line comment
		/*
			SELECT
				 fMEM.HealthPlan_Id
				,COUNT(DISTINCT CASE WHEN &Is_Nonengaged THEN CAST(NULL AS INT) ELSE fMem.Member_Id END) as N_Member
				,MAX(CASE WHEN fClm.&RevCodeField IN (%QuoteList(&Filter_RxCd_Transplant)) THEN 1 ELSE 0 END) AS Has_Transplant
/* ^ source.sas meta.procsql.sas embedded.sql comment.block.sql */
		*/
	) by lmedw;
	reset exec;
	create index HPLan_Id 
		ON work.blah;

	* single line comment;
	create table work.blah as
	select 
		col1
		,col2
		,put(datevar, YYMM6.) as Incurred_Txt
	from connection to lmedw (
			select *
			from dbo.database
			where a = b
	);

	alter table work.blah
	modify Some_Date_Field1 format=yymmddd10.
		,Some_Date_Field2 format=yymmddd10.;

	alter table work.blah
	modify 
		 Some_Date_Field1 format=yymmddd10.
		,Some_Date_Field2 format=yymmddd10.;
	
	create table work.blah as
		select * from work.blah;
	reset exec noerrorstop;
quit;
/* &myparam
*/
proc sql feedback exitcode;
	select * from work.blah group by something;
	reset exec noerrorstop errorstop;

	create table work.blah as
	select a.*, b.*
		,round(a.blah) as blah
	FROM	work.blaha a
		INNER JOIN work.blahb b
			ON a.Ident_Sk = b.Ident_Sk;
quit;


proc sql;
	* test single-line;

	create table work.people    (
	  name      char(14),
	  gender    char(6),
	  hired     num format=best8.,
	  jobtype   char(1) not null,
	  status    char(10)
	);

	alter table work.people
		add constraint prim_key primary key (name); 

	alter table work.people
			add constraint primary key gender;
	alter table work.people
	add constraint status check(status in ('permanent', 'temporary', 'terminated'));

	create table work.salary (
		name     char(14),
		salary   num not null,
		bonus    num,
		constraint for_key foreign key(name) 
			references people
			on delete restrict 
			on update set null
	  );
  quit;

%let appRoot = D:\Project_Files;
%let appName = 003_Daily_ETL;
%let appLevel = prod;
%let traceFile = &appRoot\&appName\&appLevel\output\Trace.txt;
%let ID = &sysjobid;

%let traceLine=;
%let EtlJobId = %sysfunc(compress(%sysfunc(today(),YYMMDDN8.)_ETL_&ID.));
%put * EtlJobId = &EtlJobId;

%include "&appRoot\macros\utility__SysParmRead.sas";
%SysParmRead;

%macro testDataAndProcStepInclusion(minYear_forSubset=, UseCurrProcSql=1, TestMode = %bquote(0));
	%local locIssueStatus JobStepName;

	%let locIssueStatus = -10;
	%let EmailTxtStatus =;

	options fullstimer;

	%let JobStepName = FAC_CLM_ETL_PREP;

	%if %bquote(&minYear_forSubset) EQ %str()
	%then %do;
		%let minYear_forSubset = %eval(%sysfunc(year(%sysfunc(today()))) - 2);
	%end;

	%let traceLine = subset year to at least &minYear_forSubset;

	data work.temp_Facility_Claims;
		set srcLib.Facility_Claims(where=(Claim_From_Dt >= "01JAN&minYear_forSubset."D));

		%if &TestMode
		%then %do;
			%WriteTraceRecord(&traceFile, %bquote(ETL will &traceLine));
		%end;
	run;

	%if &UseCurrProcSql = 0
	%then %do;
		proc sql;
			%connectToDBMS();
	%end; 
	reset exec noerrorstop;

	create table work.blah as
		select
			a.*
			,CASE 
				WHEN a.HPlan_Id = 1 THEN 'MA'
				WHEN a.HPlan_Id = 2 THEN 
					CASE WHEN a.LOB = 'Dual' THEN 'DUAL' ELSE 'MA' END
				ELSE ''
			 END AS TestCaseWhen format=$20. length=20
		from work.blah a;
	%SASRun_UpdateJobLog(StepNm=&JobStepName, DataSrc=&DataSourceType, StepLoc=START, status=
		,traceLine=%bquote(&traceLine), CurrJobId=&Id);
	%if &TestMode
	%then %do;
		%WriteTraceRecord(&traceFile,%bquote(Start &JobName Process));
	%end;

	%if &UseCurrProcSql = 0
	%then %do;
		quit;
	%end; 

%mend;

%testDataAndProcStepInclusion();

%let myvarlist = ABCD 010D D010X D0100 10002 0100X;
data work.blah (rename=(f=g) keep=a b c d);
	set work.blah
		(rename=(myvar=othervar) drop=superfluousVar);

	format a best12.;
	format rownum 8.;
	%let myvarlist = ABCD 010D D010X D0100 10002 0100X;

	rownum = _n_;
* test single-line comment;
a = 1;
/*  ^ unsigned integer */
a = -5;
/*  ^^ numeric constant with minus */
a = +49;
/*  ^^^ numeric constant with plus sign */
a = 1.23;
/*  ^^^^ numeric constant with decimal places */
a = 01;
/*  ^^^^ numeric constant with non-significant leading zero */

	a = 1.2e23;
/*     ^^^^^^ constant.numeric.sas */	
	a = 0.5e-10;
/*     ^^^^^^^ constant.numeric.sas */	

	a = &blah123.456;
	a = '0b0a,0b0a,0b0a'x;
/*     ^ punctuation.definition.string.begin.sas */
/*      ^^^^^^^^^^^^^^ constant.numeric.hex.sas */
/*                    ^ punctuation.definition.string.end.sas */
/*                     ^ support.constant.suffix.hex.sas */
	a = '534153'x;
/*      ^^^^^^ constant.numeric.hex.sas */
	a = '53'x; 
/*      ^^ constant.numeric.hex.sas */

	d = "01JAN2017"D;
/*     ^ punctuation.definition.string.begin.sas */
/*      ^^^^^^^^^ constant.language.date.sas */
/*               ^ punctuation.definition.string.end.sas */
/*                ^ support.constant.suffix.datetime.sas */

	b = '10000000'b;
/*     ^ punctuation.definition.string.begin.sas */
/*      ^^^^^^^^ constant.numeric.bit.sas */
/*              ^ punctuation.definition.string.end.sas */
/*               ^ support.constant.suffix.bit.sas */

run;
	* test ;
	* test;

proc means data=work.cake chartype nway noprint;
/*                        ^^^^^^^^ ^^^^ keyword.proc-means.sas; */
/*                                      ^^^^^^^ keyword.proc-generic.optionalnoprefix.sas; */
	class flavor / order=freq ascending;
	class layers / missing;
	class myvar;
	var TasteScore;
	output out=work.cakestat(where=(blah=1)) max=HighScore;
run;

data work.single work.dup;
	set work.temp;
	by HealthPlan Claim_Id;
	if 
		first.Claim_Id 
		and last.Claim_Id 
	then output work.single;
	else output work.dupe;
run;

data work.single;
	set work.temp;
	by HealthPlan Claim_Id;
	if first.Claim_Id and last.Claim_Id 
	then output;
run;


proc means 
	data=work.cake range median min max fw=7 maxdec=0
	classdata=work.caketype exclusive printalltypes;
	var TasteScore;
	title 'Taste Score For Number of Layers and Cake Flavor';
	class flavor layers;
run;

data work.convert(drop=i);
	set work.sales(drop=1) work.sales2(rename=(oldsales=sales));
	array test{*} _numeric_;
	format _numeric_ best8.;
	do i=1 to dim(test);
		test{i} = (test{i}*3);
	end;
run;

proc means data=cake fw=6 n min max median nonobs;
	class flavor/order=data;
	class  age /mlf order=fmt;
	 types flavor flavor*age;
	var TasteScore;
	format age agefmt. flavor $flvrfmt.;
	title 'Taste Score for Cake Flavors and Participant''s Age';
run;
proc summary;
by sample_number species_code;
var length;
output out=work.sum2 n=n;
run;

data work.TEMP_ClaimDB_&&TableSuffix.;
	set work.TEMP_ClaimDB_&TableSuffix.;

	select (a);
		when (1) x=x*10;
		when (2);
		when (3,4,5) x=x*100;
		otherwise;
	end;	
run;

%macro Calc_Membership_Standard(Filt_HealthplanId = 1, somethingelse=2);

	proc sql feedback exitcode;
/*          ^^^^^^^^ support.function.procsql.options.optionalnoprefix.sas */
		%connectToDBMS(ClaimDB);
/*     ^^^^^^^^^^^^^ variable.function.macro.sas */
reset exec ;
		CREATE TABLE work.TEMP_ClaimDB_&TableSuffix. AS
	/*                                ^^^^^^^^^^^^^variable.other.parameter.sas */
		SELECT 
			 HealthPlan_Id
			,IPAdmit_Qty
			,Claim_Qty
			,N_Member
			,CASE 
				WHEN Claim_Qty > 0 THEN ROUND(IPAdmit_Qty/Claim_Qty,.0000000001)
				ELSE . 
			 END AS IPAdmit_Pct
			,ROUND(IPAdmit_Qty/Claim_Qty,.0000000001) AS TestSql
		FROM CONNECTION TO ClaimDB (
	/*      ^support.function.fromconnection.sas */
	/*                    ^keyword.emphasis.connection.sas */
			SELECT
				 fMEM.HealthPlan_Id
				,fMEM.Incurred_Month
				,SUM(fCLM.IPAdmit_Qty) AS IPAdmit_Qty
				,SUM(fCLM.Claim_Qty) AS Claim_Qty
				,COUNT(DISTINCT CASE 
					WHEN &Is_Nonengaged THEN CASE WHEN fMem.CaseType = 'Risk' THEN fMem.Member_Id ELSE CAST(NULL AS INT) END
					ELSE fMem.Member_Id
				 END) as N_Member

			FROM 
				&evalTable fCLM
				INNER JOIN dbo.Member_Months fMEM
					ON  fMEM.Member_Id = fCLM.Member_Id 
					AND fMem.Incurred_Month = 
						CONVERT(DATE, DATEADD(day, 1-day(fClm.Claim_Paid_Date), fClm.Claim_Paid_Date))
			WHERE 
				fMEM.Healthplan_id = &Filt_HealthplanId
			GROUP BY 
				 fMEM.HealthPlan_Id
				,fMEM.Incurred_Month
			-- test single line comment
		);
reset exec;
/* <- procsql.reset.statement.sas */
	quit;

	%put %sysfunc(COMPBL(* retrieving &type column names for table &Table ...));

%mend;


%Calc_Membership_Standard(Filt_HealthplanId = 2);
	options nomprint compress  = yes msglevel=i mprint authserver;
/* <- meta.options.sas */

proc means n data = work.Temp;
	var Session_ID;
	class Task_ID Task_Number;
	format Task_ID $16.;
/* ^^^^^^ keyword.format.sas */
run;


proc sql feedback stimer nofeedback;
	connect to oledb  (
	);
	connect to oledb as edw (
	 );
	create table work.blah as
		select a, b, c
		from work.tbl_nm;
	reset exec;
quit;

proc sql feedback;
	connect to oledb as edw (
	 );

	select * from connection to edw (
		select a, b, c
		from dbo.mytable src
			LEFT JOIN dbo.table2 alt
				ON alt.My_Sk = src.My_Sk
	);
	reset exec;
quit;

PROC  sql feedback;
	connect to oledb as edw ( );
	create table work.blah as
	select * from connection to edw (
		select * 
		from dbo.mytablename
	 );

	disconnect from edw;
quit;
proc sql feedback;
	create table work.blah as
		select a, b
		from connection to edw (

			select *
			from sys.tables a
			where blah = 1
			/*-- where 1 = 0 */
	);
quit;

proc printto log=log new;
run;


DATA work.Claim_Detail_Part
	(KEEP = clm_sk list_fail_part_no list_fail_part_desc 
				list_repl_part_no list_repl_part_desc ) ;
	LENGTH list_fail_part_no  list_fail_part_desc $100 ;
	LENGTH list_repl_part_no list_repl_part_desc $1000;
	SET work.Claim_Detail_Part_All(WHERE=(clm_sk > 0));
	BY  clm_sk;
	lag_failed_Sk = LAG(Fail_Part_Sk) ;
	lag_Part_Qty = LAG(Adj_Part_Qty) ;

	RETAIN list_fail_part_no list_fail_part_desc 
			list_repl_part_no list_repl_part_desc;
run;			
proc printto log = "C:\temp.log" new;
run;
/*
This actually uses case-insensitive
(?i:\b(?<=from|join)\s*((@\w+)|(#{1,2}\w+)|[\w\.\]\[]+)\s+(as\s+)?(?!=\n|,|with|outer|inner|left|right|cross|where|join|on)(\w+))
*/

/*
	WISHLIST: This is invalid outside of macro. Would like to separate out
	different KINDS of keywords for the syntax highlighting.*/
	%if (1=0) 
	%then %do;
		%let nml = blah;
		%put * nml=&nml;
	%end;

/* start one comment here
	data work.blah;
		* start a single-line comment here;
	run;
*/
DATA	usr.blah;
	set work.blah;
	attrib var1 length = 12 label = 'my label here';
	describe;
run;

filename myfile _all_ clear;
filename myfile _all_ list;
filename myfile list;

data work.Temp( DROP=User_Agent User_ID Session_Created_BY Session_Last_Update_Date 
		Session_Creation_Date Task_Creation_Date Session_Status) ;
	INFORMAT Task_Creation_Date Session_Date Session_Creation_Date 
		Session_Last_Update_Date DATETIME20.;
/*                             ^constant.numeric.dateformat.I.sas */      
	FORMAT Task_Creation_Date Session_Date Session_Creation_Date Session_Last_Update_Date DATETIME20.;
/* ^keyword.datastep.sas */
  INFILE raw(sessionTasks.txt) DELIMITER = '09'x LRECL = 2000 FIRSTOBS = 2;
  INPUT  
	Session_ID 
	Task_Number 
	Task_ID :$20. 
	Task_URL :$128. 
	User_Agent :$16.
	Study_URL :$48. Task_Status   $ Task_Sequence    
	$ Task_Creation_Date:ANYDTDTM21. 
	User_ID Study_Name :$64. Session_Date :ANYDTDTM21. Session_Status:$4. 
	Session_Creation_Date : ANYDTDTM21. Session_Created_By :$24. 
	Session_Last_Update_Date :ANYDTDTM21.;
RUN;  

data work.test97;
	datalines4;
		a = b;
run;

data master;
	modify master trans; 
	by key;
	if _iorc_=0 then replace;
	else
		output;
run;

data newpay;
	update payroll(where=(a=b)) increase;
	by id;
run;

data work.final;
	merge work.blah ( keep = a b rename=( c=cc d=dd)) end=myvar
/* ^^^^^ source.sas meta.datastep.sas keyword.datastep.merge.sas */
/*       ^^^^^^^^^ source.sas meta.datastep.sas variable.function.table_name.sas */
/*                   ^^^^source.sas meta.datastep.sas keyword.datasetoption.sas */
/*                                                   ^^^ source.sas meta.datastep.sas keyword.dataset.noncontrol.sas  */
	work.blah ( keep = a b cc dd);
	by a b;
/* ^^^^^^^ meta.datastep.sas meta.by.sas */
/* ^^ meta.datastep.sas meta.by.sas keyword.statement.by.sas */
run;

data work.blah ( keep=a b rename=(c=cc d=dd));
	set work.blah;
	attrib 
		var1 ddmmyyb.
		var2 ddmmyyb8.
		var3 mmddyy.
		var4 yymmn6.
		var5 yymmc10.
		var5 yyqrc.
		var6 yymmn6.
		var7 datetime26.4
		var7b DATEAMPM22.2
		var8 $best8.2 /* this should not invoke */
		var9 best8.2
		var10 best8.
		var11 best.
		var12 month.
		var13 8.
		dvar1 = datetime26.4
		dvar = datetime.
		dvar = datetime16.
		cvar1 = $hex.
		cvar2 = $binary8.2
		var15 = binary8.2
		var15 = binary.
		zip_cd z5.
	;
	newvar = month(mydatevar);

run;

ods html close;
ods html path=WebOut FILE="Prep.SessTask.01.Raw.TaskID.htm";
ods html close;

	proc contents varnum 
/* ^^^^ support.module.proc.bgn.sas */
/*            ^^^^^^ keyword.other.proc-contents.sas */
	data=temp;
run;

%let sourceRoot = C:\Users\Nicole\Documents\SAS;
%let macroRoot = &sourceRoot\MacroLib;
/*               ^^^^^^^^^^^ variable.other.parameter.sas  */
%let appName = SampleCode;
%let appLevel = prod;
%include "&macroRoot\utility\utility__*.sas" /lrecl=4096;
%include "&sourceRoot\&appName\&appLevel\main_batch.sas" / lrecl=4096 noblock block byte message;

%let myvar = %mymacronamethatistoolongabcdefghijk();
%LET Filter_ClaimDt_Bgn_SAS = %SYSFUNC(intnx(WEEK
	,%SYSFUNC(INTNX(MONTH,%eval(%SYSFUNC(today()) - 1),-60,S))
	,0,BEGINNING)) compbl(should not work because sysfunc closed);
/*                ^^^^^^source.sas */
%LET Filter_ClaimDt_Bgn_SQL = %sysfunc(compbl(%qSYSFUNC(putn(&Filter_ClaimDt_Bgn_SAS,YYMMDDD10.))));
%LET Filter_ClaimDt_Bgn_SQL = %sysfunc(compbl(%qSYSFUNC(putn(%bquote(&Filter_ClaimDt_Bgn_SAS),YYMMDDD10.))));

%LET Filter_ClaimDt_Bgn_SQL = %SYSFUNC(putn(&Filter_ClaimDt_Bgn_SAS,YYMMDDD10.), YYMMDD.);
%put Filter_ClaimDt_Bgn_SQL=&Filter_CntctDt_Bgn_SQL;

libname test1 "C:\Users\Folder";
libname ah&testvar. "C:\Users\Folder";

%macro test;
	%LET Filter_ClaimDt_Bgn_SAS = %SYSFUNC(intnx(WEEK
		,%SYSFUNC(INTNX(MONTH,%eval(%SYSFUNC(today()) - 1),-60,S))
		,0,BEGINNING));

%mend;

data work.test;
	set work.test;
	format Filter_ClaimDt_Bgn_SAS YYMMDDD10.;

	Filter_ClaimDt_Bgn_SAS = INTNX(WEEK, INTNX(MONTH, (today() - 1), -60, S), 0, BEGINNING);
run;

proc freq data = temp (keep= a b Task_URL); 
	where a <> b;
/*         ^^ meta.proc.generic.sas keyword.operator.ne.sqlonly.sas  */
	tables Task_URL;
/* ^^^^^^ source.sas meta.proc.generic.sas meta.proc-statement-tables.sas keyword.other.statement.tables.sas */
run;
data	work.temp(sortedby=b rename=(a=b c=d));
set temp;
	by a;
format myvar datetime20.;
	/* comment */
	a = b;
	a != b;
	a ~= b;
	a ^= b;
	a ¬= b;

	/* flagging this as syntax violation. Not TECHNICALLY true, but in SAS, this is interpreted as MIN/MAX, NOT not-equal-to */
	a <> b;
	/*^^ source.sas meta.datastep.sas keyword.operator.ne.sqlonly.sas  */
	c = b || d || e;
	if a | b | c OR d;
	if a & b AND c then d;

	if a = &&paramname. 
	then do;
		/* nothing */
	end;
	if anyalpha(b) > 0
	then do;
		g = input(b, 8.);
	end;
run;
ods html;

ENDSAS;
/* <- keyword.globalstatement.optionless.sas */

MISSING  a;

proc sql;
	select *
	from work.blah
	where a <> b;
/*         ^^ keyword.operator.ne.sqlonly.sas */
quit;

data work.Temp; 
	set Temp;
	
	* IF prior row is same as current row, mark as a Repeat;
	if Session_ID = LAG(Session_ID) 
		AND Task_URL = LAG(Task_URL)
		then RepeatVar = 1; 
	else RepeatVar =0;
/* ^^^^ source.sas meta.datastep.sas keyword.control.nonmacro.sas  */
	output; 
/* ^^^^^^ variable.language.datastep-operation.sas */

RUN;
ods html close;


proc glm data=Trial;
	class Treatment;
	model PreY1 PostY1 FollowY1 PreY2 PostY2 FollowY2 = Treatment / nouni;
	repeated Response 2 identity, Time 3;
run;
proc transpose 
	data=Temp(WHERE=(Task_Number=2)) NAME=NAME OUT=GaveConsent(DROP=NAME);
	by Session_ID; 
	var Task_ID; 
	ID Task_Number;
run;

proc corr 
	DATA = Clean.Cr 
/* ^^^^ keyword.other.data-equals.sas */
/*        ^^^^^^^^ variable.function.name.table.sas */
	OUTP=IniFactor;
/* ^^^^ keyword.other.data-equals.output.sas */
/*      ^^^^^^^^ variable.function.name.table.sas */
	VAR Q01-Q11;
run; 

proc reg data=a outest=est;
	model y=x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 / selection=adjrsq sse aic;
	output out=out p=p r=r;
run;


proc glm;
	model mpg=mph mph*mph / p clm;
run;
proc glm plot=meanplot(cl);
	class drug disease;
	model y=drug disease drug*disease;
	lsmeans drug / pdiff=all adjust=tukey;
run;

/* WISHLIST: More PROC-specific keyword highlighting? */
PROC FACTOR DATA=work.IniFactor (TYPE=CORR)
	ROTATE=PROMAX
	METHOD=PRINCIPAL
	PRIORS=SMC
	MINEIGEN=1
	CONV= 0.001
	MAXITER=200
	MSA
	SIMPLE
	SCREE
	REORDER
	HEYWOOD;
RUN;
data _null_;
	 array arra a1-a10 (0 1 2 3 4 5 6 7 8 9);
	 array arrb b1-b10 (10 11 12 13 14 15 16 17 18 19);

	 _i_ = 3;
	 put _i_= arra= arrb=;
	 _i_ = 6;
	 put _i_= arra= arrb=;

	 do over arra;
		  put "Start: " _i_ =; 
		  * _i_ will be initialized to 1;
		  do over arrb;
				put _i_= arra= arrb=;
		  end;
		  put "End: " _i_=; 
		  * ;
	 end;
run; 
data score2(drop=i);
	array test{3} _temporary_ (90 80 70);
	array score{3} s1-s3;
	input id score{*};

	do i=1 to 3;
		if score{i}>=test{i} then
		do;
			NewScore=score{i};
			output;
		end;
	end;
	datalines;
	1234  99 60 82
	5678  80 85 75
	;
  run;
* test single line comment;

proc sql; 
  * single line comment;
	select * 
	from work.blah;
	reset noexec outobs=10;
	create table work.blah as
		select * from connection to edw (
			select 'blah' as myvar, *
			from dbo.mytable
			-- where 0 = 1
		);
quit;
proc report data=grocery;
	title ;
	column ('Individual Store Sales as a Percent of All Sales'
				sector manager sales,(sum pctsum) comment);
	define manager / group
						  format=$mgrfmt.;
	define sector / group
						 format=$sctrfmt.;
	define sales / format=dollar11.2
						'';
	define sum / format=dollar9.2
					 'Total Sales';
	define pctsum / 'Percent of Sales' format = percent6. style(column)=blah;
	define comment / computed style(column)=[cellwidth= 2.5in];
	compute comment / char length=40;
		if sales.pctsum gt .15 and _break_ = ' '
		then comment='Sales substantially above expectations.';
		else comment=' ';
	endcomp;
	rbreak after / summarize style=[font_style=italic];
run;


proc report data=grocery;
	column manager department sales
			 sales=salesmin
			 sales=salesmax;
	define manager / order
						  order=formatted
						  format=$mgrfmt.
						  'Manager';
	define department    / order
						  order=internal
						  format=$deptfmt.
						  'Department' ;
	define sales / analysis sum format=dollar7.2 'Sales';
	define salesmin / analysis min noprint;
	define salesmax / analysis max noprint;
  compute after;
		line 'Departmental sales ranged from'
				salesmin dollar7.2  " " 'to' " " salesmax dollar7.2;         
	endcomp;
	where sector='se';
	title 'Sales for the Southeast Sector';
	title2 "for &sysdate";
run;

proc freq data=Color order=data;
	tables Eyes*Hair / expected cellchi2 norow nocol chisq;
	output out=ChiSqData n nmiss pchi lrchi;
	weight Count;
	title 'Chi-Square Tests for 3 by 5 Table of Eye and Hair Color';
run;

proc freq data=FatComp order=data;
	format Exposure ExpFmt. Response RspFmt.;
	tables Exposure*Response / chisq relrisk;
	exact pchi or;
	weight Count;
	title 'Case-Control Study of High Fat/Cholesterol Diet';
run;
proc freq data=Pain;
	tables Adverse*Dose / trend measures cl
			 plots=freqplot(twoway=stacked orient=horizontal scale=percent);
	test smdrc;
	exact trend / maxtime=60;
	weight Count;
	title 'Clinical Trial for Treatment of Pain';
run;

proc plot data=djia formchar="|----|+|---+=|-/\<>*";
	plot high*year='*'
		  low*year='o' / overlay box
		  haxis=by 10
		  vaxis=by 5000;
	title 'Plot of Highs and Lows';
	title2 'for the Dow Jones Industrial Average';
run;


%macro showSASReadsOneLineComments;

	data work.blah;
		format rowNum 8.;
			%do i=1 %to 16;
				*** Single run %let i=1;
				rowNum = &i;
				output;
				*** End single run;
			%end;
	run;

%mend; 


proc sql;
	create table work.blah as
	select *
	from connection to edw (
		select *
		from dbo.sometable
		where a like '%ER' + 'RROR%'
	);

quit;
%let you = &&blah.&blah;

%let myvar = %abortThisIsAValidMacroNameToCap();

title1 "blah" bold;
title "blah" bold;
%macro getQuoteList(
	string
	,inDlm=%str( )
	,outDlm=%str(, )
	,quoteType=DOUBLE
	,quotingChar=%str()); 
	
	%local i locString nItem thisDlm;
	%let nItem = %getItemCountInString(&string, inDlm=&inDlm);
/*              ^entity.name.function.macro.sas */

	%if %upcase(&quoteType) = SINGLE
	%then %do;
		%let quotingChar = %str(%');
/*                            ^^ constant.character.escape.sas */
	%end;
	%else %if %upcase(&quoteType) = DOUBLE
	%then %do;
		%let quotingChar = %str(%");
/*                       ^^^^ support.function.opencode.masked.sas */
	%end;

	%do i = 1 %to &nItem;
		%if &i = 1
		%then %do;
			%let thisDlm =;
			%let locString =;
		%end;
		%else %do;
			%let thisDlm=%bquote(&outDlm);
		%end;
		%* Dummy/non-functioning line to show nested ampersand resolution;
		%let columnTypeList = &&columnName&i &&targetDataType&i;
/*                          ^              ^ variable.parameter.macro.nested.sas */
		 %let locString=&locString&thisDlm&quotingChar%nrbquote(%scan(&string, &i, &inDlm))&quotingChar;
	%end;

	%let locString = %unquote(&locString);


	%do i = 1 %to &nItem;
	%end;

	%do %while (not &done);

	%end;
%mend;

%macro testme(
	string
	,inDlm=%str( )
	,outDlm=%str(, )
	,quoteType=DOUBLE); 
	
	%if &useCurrProcSql = 0
	%then %do;
		proc sql;
	%end;

	%local i locString nItem thisDlm;
	%let nItem = %getItemCountInString(&string, inDlm=&inDlm);

	%if &useCurrProcSql = 0
	%then %do;
		quit;
	%end;

%mend;
/* Test comment */

*/
/* <- invalid.illegal.stray-comment-end.sas */
title1 "blah";

proc sql;
CREATE TABLE work.test2 AS
SELECT
	"""566 28 abc"N AS ThisIsOK
	,"566 28 abc"N AS ThisIsOK2
	,'blah blah blah'N as ThisIsOK3
	,"blah blah" as nml
	,CASE WHEN Has_ER_Code > 0 THEN 'Y' ELSE 'N' END AS Flag_OK
	,CASE WHEN Has_ER_Code > 0 THEN 'Y' ELSE 'Nope' END AS StringNeverPopsOff
	,CASE WHEN blah = '' THEN 1 ELSE 0 END as IsBlank
FROM work.test1;
title1 "blah blah";
quit;
proc means data=work.blah;
	class myclassvar;
	title1 "blah blah";
run;

proc sql;

title 'Most Current Information for Ticket Agents';
	select p.IdNumber,
			 coalesce(p2.jobcode,p.jobcode) label='Current Jobcode',
			 coalesce(p2.salary,p.salary) label='Current Salary'
		from proclib.payroll p      left join proclib.payroll2 p2
		on p.IdNumber=p2.idnum
		where p2.jobcode NOT  CONTAINS 'TA';
quit;      
title1 "blah blah";
proc sql;
		/*  */
	create table work.blah as
	select 
		Claim_Id
		,DateofServiceFrom as DOS_From_Dt
		,CASE 
			WHEN 
				HPlan_Sk IN (1, 2, 3, 4) THEN
				CASE 
					WHEN clm.LOB = 'Medicare' THEN 'MA' 
					ELSE 'DUAL'
				END
			WHEN HPlan_Sk = 5 THEN 'blah'
			WHEN HPlan_Sk = 6 THEN 'MA'
			ELSE 'UNKNOWN'
		END as Src
		,substr(Full_Brand_Nm, 1, 10) as Short_Brand_Nm length = 12 format=$12.
	from 
		legLib.Claim_Header clmH
		INNER JOIN legLib.Claim_Line clmL
			ON clmH.Claim_Head_Id = clmL.Claim_Head_Id

	union all corresponding
	select
		Claim_Id
		,DOS_From_Dt
		,'blah' As Src
		,Short_Brand_Nm
	FROM
		clmMart.Claim_Header;
quit;	

ods options reset=title;


proc sql;
	select 
		case when &Colname_Id IN (%QuoteList(&Filter_List_DxCd_Transplant)) THEN 1 ELSE 0 END as Has_Transplant_Dx
		,case when &Colname_Id IS NOT NULL THEN
					 CASE WHEN &Colname_Id = Id_Match then 'Y' else 'N' END
			  ELSE 'INSERT' END as IsMatch_ID
		,case when &Colname_Id IS NOT NULL THEN
					 CASE WHEN &Colname_Cd = Cd_Match then 'Y' else 'N' END
			  ELSE 'INSERT' END as IsMatch_Cd
		,CASE 
			WHEN ( &Colname_Id IS NOT NULL AND &Colname_Id = ID_Match )
				  OR ( &Colname_Id IS NULL AND &Colname_Id IS NULL)
				  OR ( Id_Match IS NULL AND Cd_Match IS NULL)
				  OR ( &Colname_Cd IS NOT NULL AND &Colname_Cd = Cd_Match )
			THEN 'OK' ELSE 'CHECK ME' END AS IsAligned
		,count(*) as total
	from work.Labor_Return 
	GROUP BY 1, 2, 3
;

quit;
proc sql;
	select
		house
		,store label='Closest Store'
		,sqrt((abs( s.x - h.x) ** 2)
			+(abs(h.y-s.y)**2)) as dist label='Distance' format=4.2 transcode = yes
		,count(all varname) as blah
	from stores s, houses h
	group by house
		having dist=min(dist);
quit;

proc sql;
	SELECT DataSourceType
	INTO  :templine separated by ' '
	FROM work.blah;

	SELECT COALESCE(COUNT(*), 0) AS ReqLoop_N
	INTO : ReqLoop_N
	from work.blah;

	%let ReqLoop_N =%left(&ReqLoop_N);
	SELECT 
		 DataSourceType
		,Request_Id
	INTO   
		 :reqSrc1  	- :reqSrc&ReqLoop_N
		,:reqId1   	- :reqId&ReqLoop_N
	FROM work.blah;

	SELECT DISTINCT Dlr_No
	INTO   :fqrDlrNo_In SEPARATED BY "&fqrDlm"
	FROM   work.fqrlong_unix
	WHERE  Dlr_No IS NOT NULL 
			 AND lengthn(Dlr_No) ^= 6;

	select style, sqfeet
	into :type1 - :type4 notrim, :size1 through :size3
	from sasuser.houses;			 

quit;	
proc sql;
	select * from me1
union
select * from me2;

select * from in_usa
except
select * from out_usa;

select * from in_usa
intersect
select * from out_usa;    

CREATE TABLE unionallcorr AS
SELECT * FROM one
UNION ALL CORRESPONDING
SELECT * FROM two;     

CREATE TABLE intersectall AS
SELECT * FROM abc
INTERSECT ALL
SELECT * FROM ab; 

CREATE TABLE intersectall AS
SELECT * FROM abc
INTERSECT
SELECT * FROM ab; 

CREATE TABLE exceptall AS
SELECT * FROM abc
EXCEPT ALL
SELECT * FROM ab; 

CREATE TABLE exceptall AS
SELECT * FROM abc
EXCEPT
SELECT * FROM ab; 
quit;

proc sql;
	create index area
		on sql.newcountries(area);

	create index places2
		on sql.newcountries(name, continent);
	create unique index places3
		on sql.newcountries(name, continent);

	drop index places
		, places2
		, places3
	from sql.newcountries;

	create table work.blah as
	select * from work.blah group by blah;
quit;      

data perm.accounts;
   modify perm.accounts;
   if AcctNumber=1002 then remove;
run;
proc print data=perm.accounts;
   title 'Edited Data Set';
run;

%macro testme;

		proc report data=work.sse_Data nowd split=' ' spacing=0;

			%if &SummaryType = PLIST 
			%then %do;
				column StepId StepName Status StepTime Crt_Tmstmp Upd_Tmstmp;

				define StepId / ORDER "Step ID" format=8.0;
				define StepName / DISPLAY "Step Name";
				define Crt_Tmstmp / DISPLAY "Create Tmstmp" format=MDYAMPM17.;
				define Upd_Tmstmp / DISPLAY "Update Tmstmp" format=tod8.;
			%end;

			%else %if &SummaryType = NONWARRTTB_ETL 
			%then %do;
				column JobId DataSourceType JobName JobStepName 
					JobStepId StepTime Status JobStepLocation  Description End_Dt;
			%end;

			%else %if &SummaryType = PLIST_CHECK_NONWARR 
			%then %do;
				column DataSourceType JobName JobStepName 
					 Status StepTime JobStepLocation End_Dt Description JobId JobStepId;
				/* cant combine with other definitions, it is an ORDER here */
				define JobStepName / ORDER "Job Step Name" width=5 flow; 
			%end;

			%else %if &SummaryType = ACS_ETL 
			%then %do;
				column  JobStepName StepTime Status JobStepLocation End_Dt Sas_Dt 
				Description  N0 N1 N2 N3 N4 N5 N6 ;

				define Sas_Dt / Display "SAS Data Date" format=MDYAMPM17.;
				define N0 / Display "SAS N" format=comma9.;
				define N1 / Display 'Chk SQL' format=comma9.;
				define N2 / Display 'Chk SAS' format=comma9.;
				define N3 / Display 'In Scope' format=comma9.;
				define N4 / Display 'Dels' format=comma7.;
				define N5 / Display 'Ins' format=comma7.;
				define N6 / Display 'Upd' format=comma7.;
			%end;
			
			%else %if &SummaryType = RERUN 
			%then %do;
				column JobReRunId JobStepId JobId
					JobRerunCount JobRerunEmailType
					Status JobStepLocation 
					JobStepName Description End_Dt;
			
				define JobReRunId / order "Job Rerun Id";
				define JobRerunCount / Display "Rerun N";
				define JobRerunEmailType / Display "Email Type";
			%end;


			%if 
				&SummaryType = ACS_ETL 
				OR &SummaryType = NONWARRTTB_ETL 
				OR &SummaryType = PLIST 
				OR &SummaryType = PLIST_CHECK_NONWARR 
				OR &SummaryType = RERUN 
			%then %do;
				define Status / Display "Status";
				define StepTime / Display "Step Time" format=MMSS8.1;

				%if 	
					&SummaryType = ACS_ETL 
					OR &SummaryType = NONWARRTTB_ETL 
					OR &SummaryType = RERUN 
				%then %do;
					define JobStepName / Display "Job Step Name" width=5 flow ;
				%end;

				%if 
					&SummaryType = NONWARRTTB_ETL 
					OR &SummaryType = PLIST_CHECK_NONWARR
				%then %do;
					define DataSourceType / order "Data Src";
					define JobName / order "Job Name";
				%end;

				%if 
					&SummaryType = NONWARRTTB_ETL 
					OR &SummaryType = PLIST_CHECK_NONWARR
					OR &SummaryType = RERUN
				%then %do;
					define JobId / order "Job Id";
					define JobStepId / order "Stp Id";
				%end;

				%if 	
					&SummaryType = ACS_ETL 
					OR &SummaryType = NONWARRTTB_ETL 
					OR &SummaryType = PLIST_CHECK_NONWARR
					OR &SummaryType = RERUN 
				%then %do;
					define Description / Display "Text"  width=100 flow ;
					define JobStepLocation / Display "Step Loc";
					define End_Dt / Display "End Date" format=tod8.;
				%end;

			%end;

		run;

%mend;

data testlength;
	informat FirstName LastName $15. n1 6.2;
	input firstname lastname n1 n2;
	length name $25 default=4;
	name=trim(lastname)||', '||firstname;
	datalines;
Alexander Robinson 35 11
;
run;


goptions reset=title;

proc sql;
	select
	*
	from work.blah;
quit;
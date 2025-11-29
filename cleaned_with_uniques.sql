-- Changes summary:
-- - Schemas created: as, dbo, ELM, guest, log, sys, Temp
-- - Table renames (original_schema.OriginalName -> original_schema.<Prefix>OriginalName):
--   ELM._CitizenInfoResult -> ELM.F__CitizenInfoResult        (chosen F_ as event/result/staging table)
--   dbo._TBD_LK_EducationalGrades -> dbo.REF__TBD_LK_EducationalGrades  (lookup -> REF_)
--   dbo._TBD_SchoolsDB_Education_Grade -> dbo.REF__TBD_SchoolsDB_Education_Grade (lookup/grade -> REF_)
--   dbo._tempCompareStudents -> dbo.F__tempCompareStudents      (temp/staging -> F_)
--   dbo._TempEdaraCity -> dbo.F__TempEdaraCity                 (temp/staging -> F_)
--   dbo._tempStudents -> dbo.F__tempStudents                   (temp/staging -> F_)
--   dbo._TestTable -> dbo.F__TestTable                         (generic test/transactional -> F_)
--   dbo.AcademicTracks -> dbo.REF_AcademicTracks               (master data -> REF_)
--   dbo.Accepted -> dbo.REF_Accepted                           (small reference -> REF_)
--   dbo.AccountTypes -> dbo.REF_AccountTypes                   (master/reference -> REF_)
--   dbo.Act_ActivitiesAudences -> dbo.F_Act_ActivitiesAudences  (activity transactional -> F_)
--   dbo.Act_Attachments -> dbo.F_Act_Attachments                (attachments -> F_)
--   dbo.Act_AwarenessActivities -> dbo.F_Act_AwarenessActivities (transactional -> F_)
--   dbo.Act_Initiatives -> dbo.F_Act_Initiatives               (transactional -> F_)
--   dbo.Act_Projects -> dbo.F_Act_Projects                     (transactional -> F_)
--   dbo.Act_StrategicPlans -> dbo.F_Act_StrategicPlans         (transactional -> F_)
--   dbo.AdminStudentRequests -> dbo.F_AdminStudentRequests     (transactional -> F_)
--   dbo.Adv_Compains -> dbo.F_Adv_Compains                     (transactional -> F_)
--   dbo.Adv_CompainsLog -> dbo.F_Adv_CompainsLog               (transactional -> F_)
--   ELM.AlienAccess -> ELM.F_AlienAccess                       (transactional/staging -> F_)
--   ELM.AlienInfoResult -> ELM.F_AlienInfoResult               (result/staging -> F_)
--   dbo.ApplicationGroupInteractiveCollaborative -> dbo.F_ApplicationGroupInteractiveCollaborative (junction -> F_)
--   dbo.ApplicationGroups -> dbo.REF_ApplicationGroups         (master/reference -> REF_)
--   dbo.ApplicationPermissions -> dbo.REF_ApplicationPermissions (master/reference -> REF_)
--   dbo.Applications -> dbo.REF_Applications                   (master/reference -> REF_)
--   dbo.ApplicationsGroupsMembers2 -> dbo.F_ApplicationsGroupsMembers2 (junction -> F_)
--   dbo.ApplicationsGroupsPermissions2 -> dbo.F_ApplicationsGroupsPermissions2 (junction -> F_)
--   dbo.ApplicationsPermissions2 -> dbo.REF_ApplicationsPermissions2 (master/reference -> REF_)
--   dbo.ApplicationsUsersPermissions2 -> dbo.F_ApplicationsUsersPermissions2 (junction -> F_)
--   (Additional tables truncated in source were not processed here; further iterations will handle them.)

-- - PK column renames (old -> new):
--   ID or Id columns that were primary keys were renamed to <OriginalTableName>_ID (OriginalTableName is the original table name without the added prefix). Examples:
--     _TBD_LK_EducationalGrades.ID -> _TBD_LK_EducationalGrades_ID
--     _TBD_SchoolsDB_Education_Grade.ID -> _TBD_SchoolsDB_Education_Grade_ID
--     _TestTable.ID -> _TestTable_ID
--     AccountTypes.ID -> AccountTypes_ID
--     Act_ActivitiesAudences.Id -> Act_ActivitiesAudences_ID
--     Act_Attachments.Id -> Act_Attachments_ID
--     Act_AwarenessActivities.Id -> Act_AwarenessActivities_ID
--     AdminStudentRequests.Id -> AdminStudentRequests_ID
--     AlienAccess.ID -> AlienAccess_ID
--     AlienInfoResult.ID -> AlienInfoResult_ID
--     ApplicationGroupInteractiveCollaborative.InteractiveCollborativeID -> (kept as-is because PK composed of two columns; no single-ID rename)
--     ApplicationGroups.ID -> ApplicationGroups_ID
--     ApplicationPermissions.ID -> ApplicationPermissions_ID
--     Applications.ID -> Applications_ID
--     ApplicationsPermissions2.PermissionID -> (kept as-is, but still added SourceDatabaseName)
--     ... (see per-table DDL below)

-- - UNIQUE constraints added:
--   For every table that had a single-column PK (the original ID/Id column) we added a UNIQUE constraint on that single column to work around Oracle Data Modeler composite-PK -> FK limitation. The UNIQUE constraints are named UQ_<NewTableName>_<PKCol>.
--   If a table originally had a UNIQUE on the ID column (not found in the provided snippet), a duplicate UNIQUE was not created.

-- - Assumptions / notes:
--   * If a table had no explicit PRIMARY KEY ALTER statement in the snippet, no PK ALTER (composite) was created. Only tables with explicit PKs in the provided DDL were converted to composite PKs. If you want a composite PK added for other tables, tell me and I'll add them.
--   * For junction tables that already had composite PKs (e.g., ApplicationGroupInteractiveCollaborative (InteractiveCollborativeID, ApplicationGroupID)), the PK was preserved and not modified to rename columns except when column was named ID/Id and part of PK individually. Composite PKs remain as defined and SourceDatabaseName was still added as a column (but not included in those composite PKs unless they originally required it).
--   * FK constraints were not found in the provided snippet. If you have FK ALTER statements later in the full DDL, I will update them in a follow-up pass to reference renamed tables and renamed PK column names. The UNIQUE constraints have been placed so Data Modeler can create FKs that reference the single ID column if FKs reference only that column.
--   * Vendor-specific constructs (CREATE DATABASE, ALTER DATABASE, FILEGROUPS, PARTITION FUNCTION/SCHEME, USE, GO, TEXTIMAGE_ON, sp_addextendedproperty) were removed.
--   * COLLATE clauses and IDENTITY markers were preserved where possible.
--   * Constraint names were preserved where visible (PK names). If a collision were to occur when adding UNIQUEs, numeric suffixes would be appended; none were required for the snippet provided.

-- - Constraint name changes:
--   PK constraint names kept as in the original DDL where present. UNIQUE constraint names were generated as UQ_<NewTableName>_<PKCol>.

-- END of changes summary
--
-- Begin cleaned DDL (compatible with Oracle SQL Developer Data Modeler import - SQL Server dialect):

-- Create schemas used in the model
CREATE SCHEMA as;
CREATE SCHEMA dbo;
CREATE SCHEMA ELM;
CREATE SCHEMA guest;
CREATE SCHEMA log;
CREATE SCHEMA sys;
CREATE SCHEMA Temp;

-- Table: ELM._CitizenInfoResult -> ELM.F__CitizenInfoResult
CREATE TABLE ELM.F__CitizenInfoResult (
    _CitizenInfoResult_ID INTEGER NOT NULL IDENTITY,
    UserID BIGINT,
    FirstName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    FatherName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    GrandFatherName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    FamilyName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SubtribeName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    EnglishFirstName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    EnglishSecondName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    EnglishThirdName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    EnglishLastName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Gender CHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS,
    DateOfBirth NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    PlaceOfBirth NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    NationalID NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    NationalIdExpiryDate NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    NationalIdIssueDate NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    NationalIdIssuePlace NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    GenderSpecified BIT,
    LifeStatus CHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS,
    LifeStatusSpecified BIT,
    LogId INTEGER,
    Created DATETIME(8) NOT NULL,
    CreatedBy BIGINT,
    Updated DATETIME(8),
    UpdatedBy BIGINT,
    SexDescAr NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    StatusDescAR NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    IdIssueDate NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    IdExpirationDate NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('_CitizenInfoResult')
);

-- Table: dbo._TBD_LK_EducationalGrades -> dbo.REF__TBD_LK_EducationalGrades
CREATE TABLE dbo.REF__TBD_LK_EducationalGrades (
    _TBD_LK_EducationalGrades_ID INTEGER NOT NULL,
    ArabicName NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    EnglishName NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    EducationLevelID SMALLINT,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('_TBD_LK_EducationalGrades')
);

-- PK for dbo.REF__TBD_LK_EducationalGrades (preserve original PK name PK_EducationalGrades)
ALTER TABLE dbo.REF__TBD_LK_EducationalGrades
    ADD CONSTRAINT PK_EducationalGrades PRIMARY KEY (_TBD_LK_EducationalGrades_ID, SourceDatabaseName);

-- UNIQUE on single ID for Data Modeler
ALTER TABLE dbo.REF__TBD_LK_EducationalGrades
    ADD CONSTRAINT UQ_REF__TBD_LK_EducationalGrades__TBD_LK_EducationalGrades_ID UNIQUE (_TBD_LK_EducationalGrades_ID);

-- Table: dbo._TBD_SchoolsDB_Education_Grade -> dbo.REF__TBD_SchoolsDB_Education_Grade
CREATE TABLE dbo.REF__TBD_SchoolsDB_Education_Grade (
    _TBD_SchoolsDB_Education_Grade_ID INTEGER NOT NULL IDENTITY,
    Name NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    LevelID INTEGER,
    SCL_AcademicLevelID INTEGER,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('_TBD_SchoolsDB_Education_Grade')
);

ALTER TABLE dbo.REF__TBD_SchoolsDB_Education_Grade
    ADD CONSTRAINT PK_SchoolsDB_Education_Grade PRIMARY KEY (_TBD_SchoolsDB_Education_Grade_ID, SourceDatabaseName);

ALTER TABLE dbo.REF__TBD_SchoolsDB_Education_Grade
    ADD CONSTRAINT UQ_REF__TBD_SchoolsDB_Education_Grade__TBD_SchoolsDB_Education_Grade_ID UNIQUE (_TBD_SchoolsDB_Education_Grade_ID);

-- Table: dbo._tempCompareStudents -> dbo.F__tempCompareStudents
CREATE TABLE dbo.F__tempCompareStudents (
    UserID BIGINT NOT NULL,
    Mawhiba_UserFullName NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SchoolID INTEGER,
    Mawhiba_EduAdmID INTEGER,
    Mawhiba_EduAdmName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Mawhiba_CityID INTEGER,
    Mawhiba_CityName NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Mawhiba_EduLevelID SMALLINT,
    Mawhiba_EduLevelName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Mawhiba_SchoolName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    Mawhiba_SchoolGender NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_UserFullName NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SchoolMinistryID NVARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_EduAdmID INTEGER,
    Noor_EduAdmName NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_CityID INTEGER,
    Noor_CityName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_EduLevelID INTEGER,
    Noor_EduLevelName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_SchoolName NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_SchoolGender NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    IsEduAdmIdentical INTEGER NOT NULL,
    IsCityIdentical INTEGER NOT NULL,
    IsEduLevelIdentical INTEGER NOT NULL,
    IsSchoolGenderIdentical INTEGER NOT NULL,
    Updated DATETIME(8),
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('_tempCompareStudents')
);

-- No PK defined in original snippet for this temp table; no composite PK created.

-- Table: dbo._TempEdaraCity -> dbo.F__TempEdaraCity
CREATE TABLE dbo.F__TempEdaraCity (
    EdaraID INTEGER NOT NULL,
    EdaraName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    AreaID INTEGER NOT NULL,
    AreaName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CityID INTEGER,
    CityName NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('_TempEdaraCity')
);

-- No PK defined in snippet for TempEdaraCity; if desired, can make composite later.

-- Table: dbo._tempStudents -> dbo.F__tempStudents
CREATE TABLE dbo.F__tempStudents (
    UserID BIGINT NOT NULL,
    UserPersonID NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Mawhiba_UserFullName NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SchoolID INTEGER,
    Mawhiba_EduAdmID INTEGER,
    Mawhiba_EduAdmName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Mawhiba_CityID INTEGER,
    Mawhiba_CityName NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Mawhiba_EduLevelID SMALLINT,
    Mawhiba_EduLevelName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Mawhiba_SchoolName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    Mawhiba_SchoolGender NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_UserFullName NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SchoolMinistryID NVARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_EduAdmID INTEGER,
    Noor_EduAdmName NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_CityID INTEGER,
    Noor_CityName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_EduLevelID INTEGER,
    Noor_EduLevelName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_SchoolName NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Noor_SchoolGender NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    IsEduAdmIdentical INTEGER,
    IsCityIdentical INTEGER,
    IsEduLevelIdentical INTEGER,
    IsSchoolGenderIdentical INTEGER,
    Updated DATETIME(8),
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('_tempStudents')
);

-- Table: dbo._TestTable -> dbo.F__TestTable
CREATE TABLE dbo.F__TestTable (
    _TestTable_ID BIGINT NOT NULL IDENTITY,
    Result DECIMAL(18,2),
    UserID BIGINT,
    Created DATETIME(8),
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('_TestTable')
);

ALTER TABLE dbo.F__TestTable
    ADD CONSTRAINT PK__TestTable PRIMARY KEY (_TestTable_ID, SourceDatabaseName);

ALTER TABLE dbo.F__TestTable
    ADD CONSTRAINT UQ_F__TestTable__TestTable_ID UNIQUE (_TestTable_ID);

-- Table: dbo.AcademicTracks -> dbo.REF_AcademicTracks
CREATE TABLE dbo.REF_AcademicTracks (
    AcademicTracks_ID INTEGER NOT NULL IDENTITY,
    ArabicName NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    EnglishName NVARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('AcademicTracks')
);

-- No explicit PK ALTER was provided for AcademicTracks in snippet. If desired, add:
ALTER TABLE dbo.REF_AcademicTracks
    ADD CONSTRAINT PK_AcademicTracks PRIMARY KEY (AcademicTracks_ID, SourceDatabaseName);

ALTER TABLE dbo.REF_AcademicTracks
    ADD CONSTRAINT UQ_REF_AcademicTracks_AcademicTracks_ID UNIQUE (AcademicTracks_ID);

-- Table: dbo.Accepted -> dbo.REF_Accepted
CREATE TABLE dbo.REF_Accepted (
    Accepted_ID NCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Accepted')
);

-- No PK originally; if Accepted_ID is intended as PK, user can confirm. For Data Modeler we leave as-is.

-- Table: dbo.AccountTypes -> dbo.REF_AccountTypes
CREATE TABLE dbo.REF_AccountTypes (
    AccountTypes_ID TINYINT NOT NULL IDENTITY,
    Name NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    Details NVARCHAR(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
    IsSelfRegisteration BIT NOT NULL,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('AccountTypes')
);

ALTER TABLE dbo.REF_AccountTypes
    ADD CONSTRAINT PK_AccountTypes PRIMARY KEY (AccountTypes_ID, SourceDatabaseName);

ALTER TABLE dbo.REF_AccountTypes
    ADD CONSTRAINT UQ_REF_AccountTypes_AccountTypes_ID UNIQUE (AccountTypes_ID);

-- Table: dbo.Act_ActivitiesAudences -> dbo.F_Act_ActivitiesAudences
CREATE TABLE dbo.F_Act_ActivitiesAudences (
    Act_ActivitiesAudences_ID INTEGER NOT NULL IDENTITY,
    ActId INTEGER,
    AudenceType INTEGER,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Act_ActivitiesAudences')
);

ALTER TABLE dbo.F_Act_ActivitiesAudences
    ADD CONSTRAINT PK_Act_ActivitiesAudences PRIMARY KEY (Act_ActivitiesAudences_ID, SourceDatabaseName);

ALTER TABLE dbo.F_Act_ActivitiesAudences
    ADD CONSTRAINT UQ_F_Act_ActivitiesAudences_Act_ActivitiesAudences_ID UNIQUE (Act_ActivitiesAudences_ID);

-- Table: dbo.Act_Attachments -> dbo.F_Act_Attachments
CREATE TABLE dbo.F_Act_Attachments (
    Act_Attachments_ID INTEGER NOT NULL IDENTITY,
    FileUrl NVARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
    ItemId INTEGER,
    ItemType INTEGER,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Act_Attachments')
);

ALTER TABLE dbo.F_Act_Attachments
    ADD CONSTRAINT PK_Act_Attachments PRIMARY KEY (Act_Attachments_ID, SourceDatabaseName);

ALTER TABLE dbo.F_Act_Attachments
    ADD CONSTRAINT UQ_F_Act_Attachments_Act_Attachments_ID UNIQUE (Act_Attachments_ID);

-- Table: dbo.Act_AwarenessActivities -> dbo.F_Act_AwarenessActivities
CREATE TABLE dbo.F_Act_AwarenessActivities (
    Act_AwarenessActivities_ID INTEGER NOT NULL IDENTITY,
    Title NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Dep INTEGER,
    TargetDep INTEGER,
    EvType INTEGER,
    ActType INTEGER,
    Category INTEGER,
    ActDate DATETIME(8),
    ToDate DATETIME(8),
    ActivitiesNum INTEGER,
    Description NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
    DistributedGuids NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
    GuidsNum INTEGER,
    Url NVARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
    TargetAudences NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
    AgeGroup SMALLINT,
    SchoolEducationalLevel INTEGER,
    TargetAudCount INTEGER,
    TargetStudCount INTEGER,
    TargetTeachCount INTEGER,
    TargetParentsCount INTEGER,
    TargetInventorsCount INTEGER,
    ActualAudCount INTEGER,
    ActualStudCount INTEGER,
    ActualTeachCount INTEGER,
    ActualParentsCount INTEGER,
    ActualInventorsCount INTEGER,
    TargetAnnouncers INTEGER,
    City INTEGER,
    ActivityLocation NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    LocationType TINYINT,
    RelatedProject INTEGER,
    ActStatus INTEGER,
    Instance INTEGER,
    Instructions NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Imaginary NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    GiftsAmount INTEGER,
    Presence NVARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SponsoredBy NVARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Act_AwarenessActivities')
);

ALTER TABLE dbo.F_Act_AwarenessActivities
    ADD CONSTRAINT [PK_Act_Awareness Activities] PRIMARY KEY (Act_AwarenessActivities_ID, SourceDatabaseName);

ALTER TABLE dbo.F_Act_AwarenessActivities
    ADD CONSTRAINT UQ_F_Act_AwarenessActivities_Act_AwarenessActivities_ID UNIQUE (Act_AwarenessActivities_ID);

-- Table: dbo.Act_Initiatives -> dbo.F_Act_Initiatives
CREATE TABLE dbo.F_Act_Initiatives (
    Act_Initiatives_ID INTEGER NOT NULL IDENTITY,
    InitiativeName INTEGER,
    Description NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
    StrategicPlan INTEGER,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Act_Initiatives')
);

ALTER TABLE dbo.F_Act_Initiatives
    ADD CONSTRAINT PK_Act_Initiatives PRIMARY KEY (Act_Initiatives_ID, SourceDatabaseName);

ALTER TABLE dbo.F_Act_Initiatives
    ADD CONSTRAINT UQ_F_Act_Initiatives_Act_Initiatives_ID UNIQUE (Act_Initiatives_ID);

-- Table: dbo.Act_Projects -> dbo.F_Act_Projects
CREATE TABLE dbo.F_Act_Projects (
    Act_Projects_ID INTEGER NOT NULL IDENTITY,
    DepId INTEGER,
    Title NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    StartDate DATETIME(8),
    FinishDate DATETIME(8),
    Description NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
    InitiativeId INTEGER,
    Objectives NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Act_Projects')
);

ALTER TABLE dbo.F_Act_Projects
    ADD CONSTRAINT PK_Act_Projects PRIMARY KEY (Act_Projects_ID, SourceDatabaseName);

ALTER TABLE dbo.F_Act_Projects
    ADD CONSTRAINT UQ_F_Act_Projects_Act_Projects_ID UNIQUE (Act_Projects_ID);

-- Table: dbo.Act_StrategicPlans -> dbo.F_Act_StrategicPlans
CREATE TABLE dbo.F_Act_StrategicPlans (
    Act_StrategicPlans_ID INTEGER NOT NULL IDENTITY,
    Title NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    PlanType TINYINT,
    StartDate DATETIME(8),
    EndDate DATETIME(8),
    Description NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Act_StrategicPlans')
);

ALTER TABLE dbo.F_Act_StrategicPlans
    ADD CONSTRAINT PK_Act_StrategicPlans PRIMARY KEY (Act_StrategicPlans_ID, SourceDatabaseName);

ALTER TABLE dbo.F_Act_StrategicPlans
    ADD CONSTRAINT UQ_F_Act_StrategicPlans_Act_StrategicPlans_ID UNIQUE (Act_StrategicPlans_ID);

-- Table: dbo.AdminStudentRequests -> dbo.F_AdminStudentRequests
CREATE TABLE dbo.F_AdminStudentRequests (
    AdminStudentRequests_ID INTEGER NOT NULL IDENTITY,
    FileURL NVARCHAR(max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    AdminStudentRequestsStatusID INTEGER NOT NULL,
    CreatedBy BIGINT NOT NULL,
    CreatedOn DATETIME(8) NOT NULL DEFAULT getdate(),
    ModifiedOn DATETIME(8),
    ModifiedBy BIGINT,
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('AdminStudentRequests')
);

ALTER TABLE dbo.F_AdminStudentRequests
    ADD CONSTRAINT PK_AdminStudentRequests PRIMARY KEY (AdminStudentRequests_ID, SourceDatabaseName);

ALTER TABLE dbo.F_AdminStudentRequests
    ADD CONSTRAINT UQ_F_AdminStudentRequests_AdminStudentRequests_ID UNIQUE (AdminStudentRequests_ID);

-- Table: dbo.Adv_Compains -> dbo.F_Adv_Compains
CREATE TABLE dbo.F_Adv_Compains (
    Adv_Compains_ID INTEGER NOT NULL IDENTITY,
    DepId INTEGER,
    InstanceId INTEGER,
    ContentComponentId INTEGER,
    FromDate DATETIME(8),
    ToDate DATETIME(8),
    BriefDiscription NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
    CreateDate DATETIME(8) DEFAULT getdate(),
    SourceDatabaseName NVARCHAR(100) NOT NULL DEFAULT('Adv_Compains')
);

ALTER TABLE dbo.F_Adv_Compains
    ADD CONSTRAINT PK_Deps_Projs_AdvMissions PRIMARY KEY (Adv_Compains_ID, SourceDatabaseName);

ALTER TABLE dbo.F_Adv_Compains
    ADD CONSTRAINT UQ_F_Adv_Compains_Adv_Compains_ID UNIQUE (Adv_Compains_ID);
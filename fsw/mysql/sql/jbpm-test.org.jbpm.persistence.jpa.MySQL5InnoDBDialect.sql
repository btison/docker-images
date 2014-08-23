
    create table if not exists Attachment (
        id bigint not null auto_increment,
        accesstype integer,
        attachedat datetime,
        attachmentcontentid bigint not null,
        contenttype varchar(255),
        name varchar(255),
        attachment_size integer,
        attachedby_id varchar(255),
        TaskData_Attachments_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists BAMTaskSummary (
        pk bigint not null auto_increment,
        createddate datetime,
        duration bigint,
        enddate datetime,
        processinstanceid bigint not null,
        startdate datetime,
        status varchar(255),
        taskid bigint not null,
        taskname varchar(255),
        userid varchar(255),
        primary key (pk)
    ) ENGINE=InnoDB;

    create table if not exists BooleanExpression (
        id bigint not null auto_increment,
        expression longtext,
        type varchar(255),
        Escalation_Constraints_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists Content (
        id bigint not null auto_increment,
        content longblob,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists ContextMappingInfo (
        mappingid bigint not null auto_increment,
        CONTEXT_ID varchar(255) not null,
        KSESSION_ID integer not null,
        OPTLOCK integer,
        primary key (mappingid)
    ) ENGINE=InnoDB;

    create table if not exists CorrelationKeyInfo (
        keyId bigint not null auto_increment,
        name varchar(255),
        processinstanceid bigint not null,
        OPTLOCK integer,
        primary key (keyId)
    ) ENGINE=InnoDB;

    create table if not exists CorrelationPropertyInfo (
        propertyId bigint not null auto_increment,
        name varchar(255),
        value varchar(255),
        OPTLOCK integer,
        correlationkey_keyId bigint,
        primary key (propertyId)
    ) ENGINE=InnoDB;

    create table if not exists Deadline (
        id bigint not null auto_increment,
        deadline_date datetime,
        escalated smallint,
        Deadlines_StartDeadLine_Id bigint,
        Deadlines_EndDeadLine_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists Delegation_delegates (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists Escalation (
        id bigint not null auto_increment,
        name varchar(255),
        Deadline_Escalation_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists EventTypes (
        InstanceId bigint not null,
        element varchar(255)
    ) ENGINE=InnoDB;

    create table if not exists I18NText (
        id bigint not null auto_increment,
        language varchar(255),
        shorttext varchar(255),
        text longtext,
        Task_Subjects_Id bigint,
        Task_Names_Id bigint,
        Task_Descriptions_Id bigint,
        Reassignment_Documentation_Id bigint,
        Notification_Subjects_Id bigint,
        Notification_Names_Id bigint,
        Notification_Documentation_Id bigint,
        Notification_Descriptions_Id bigint,
        Deadline_Documentation_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists NodeInstanceLog (
        id bigint not null auto_increment,
        connection varchar(255),
        log_date datetime,
        externalid varchar(255),
        nodeid varchar(255),
        nodeinstanceid varchar(255),
        nodename varchar(255),
        nodetype varchar(255),
        processid varchar(255),
        processinstanceid bigint not null,
        type integer not null,
        workitemid bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists Notification (
        DTYPE varchar(31) not null,
        id bigint not null auto_increment,
        priority integer not null,
        Escalation_Notifications_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists Notification_BAs (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists Notification_Recipients (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists Notification_email_header (
        Notification_id bigint not null,
        emailheaders_id bigint not null,
        emailheaders_mapkey_key_mapkey varchar(255) not null,
        primary key (Notification_id, emailheaders_mapkey_key_mapkey)
    ) ENGINE=InnoDB;

    create table if not exists OrganizationalEntity (
        DTYPE varchar(31) not null,
        id varchar(255) not null,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists PeopleAssignments_BAs (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists PeopleAssignments_ExclOwners (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists PeopleAssignments_PotOwners (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists PeopleAssignments_Recipients (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists PeopleAssignments_Stakeholders (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists ProcessInstanceInfo (
        InstanceId bigint not null auto_increment,
        lastmodificationdate datetime,
        lastreaddate datetime,
        processid varchar(255),
        processinstancebytearray longblob,
        startdate datetime,
        state integer not null,
        OPTLOCK integer,
        primary key (InstanceId)
    ) ENGINE=InnoDB;

    create table if not exists ProcessInstanceLog (
        id bigint not null auto_increment,
        duration bigint,
        end_date datetime,
        externalid varchar(255),
        user_identity varchar(255),
        outcome varchar(255),
        parentprocessinstanceid bigint,
        processid varchar(255),
        processinstanceid bigint not null,
        processname varchar(255),
        processversion varchar(255),
        start_date datetime,
        status integer,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists Reassignment (
        id bigint not null auto_increment,
        Escalation_Reassignments_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists Reassignment_potentialOwners (
        task_id bigint not null,
        entity_id varchar(255) not null
    ) ENGINE=InnoDB;

    create table if not exists SessionInfo (
        id integer not null auto_increment,
        lastmodificationdate datetime,
        rulesbytearray longblob,
        startdate datetime,
        OPTLOCK integer,
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists Task (
        id bigint not null auto_increment,
        archived smallint,
        delegation_allowedtodelegate varchar(255),
        formname varchar(255),
        priority integer not null,
        subtaskstrategy varchar(255),
        taskdata_activationtime datetime,
        taskdata_createdon datetime,
        taskdata_deploymentid varchar(255),
        taskdata_documentaccesstype integer,
        taskdata_documentcontentid bigint not null,
        taskdata_documenttype varchar(255),
        taskdata_expirationtime datetime,
        taskdata_faultaccesstype integer,
        taskdata_faultcontentid bigint not null,
        taskdata_faultname varchar(255),
        taskdata_faulttype varchar(255),
        taskdata_outputaccesstype integer,
        taskdata_outputcontentid bigint not null,
        taskdata_outputtype varchar(255),
        taskdata_parentid bigint not null,
        taskdata_previousstatus integer,
        taskdata_processid varchar(255),
        taskdata_processinstanceid bigint not null,
        taskdata_processsessionid integer not null,
        taskdata_skipable boolean not null,
        taskdata_status varchar(255),
        taskdata_workitemid bigint not null,
        tasktype varchar(255),
        OPTLOCK integer,
        peopl_assign_taskinitiator_id varchar(255),
        taskdata_actualowner_id varchar(255),
        taskdata_createdby_id varchar(255),
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists TaskEvent (
        id bigint not null auto_increment,
        logtime datetime,
        taskid bigint,
        type varchar(255),
        userid varchar(255),
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists VariableInstanceLog (
        id bigint not null auto_increment,
        log_date datetime,
        externalid varchar(255),
        oldvalue varchar(255),
        processid varchar(255),
        processinstanceid bigint not null,
        value varchar(255),
        variableid varchar(255),
        variableinstanceid varchar(255),
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists WorkItemInfo (
        workitemid bigint not null auto_increment,
        creationdate datetime,
        name varchar(255),
        processinstanceid bigint not null,
        state bigint not null,
        OPTLOCK integer,
        workitembytearray longblob,
        primary key (workitemid)
    ) ENGINE=InnoDB;

    create table if not exists email_header (
        id bigint not null auto_increment,
        body longtext,
        fromAddress varchar(255),
        language varchar(255),
        replyToAddress varchar(255),
        subject varchar(255),
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists task_comment (
        id bigint not null auto_increment,
        addedat datetime,
        text longtext,
        addedby_id varchar(255),
        TaskData_Comments_Id bigint,
        primary key (id)
    ) ENGINE=InnoDB;

    call execute_if_exists('alter table Attachment 
        add index FK_9jaco4irrkskr5phh97x2fe9h (attachedby_id), 
        add constraint FK_9jaco4irrkskr5phh97x2fe9h 
        foreign key (attachedby_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table Attachment 
        add index FK_hqupx569krp0f0sgu9kh87513 (TaskData_Attachments_Id), 
        add constraint FK_hqupx569krp0f0sgu9kh87513 
        foreign key (TaskData_Attachments_Id) 
        references Task (id)');

    call execute_if_exists('alter table BooleanExpression 
        add index FK_394nf2qoc0k9ok6omgd6jtpso (Escalation_Constraints_Id), 
        add constraint FK_394nf2qoc0k9ok6omgd6jtpso 
        foreign key (Escalation_Constraints_Id) 
        references Escalation (id)');

    call execute_if_exists('alter table CorrelationPropertyInfo 
        add index FK_1mgvtkn3h0bxu2fd657apkvxs (correlationkey_keyId), 
        add constraint FK_1mgvtkn3h0bxu2fd657apkvxs 
        foreign key (correlationkey_keyId) 
        references CorrelationKeyInfo (keyId)');

    call execute_if_exists('alter table Deadline 
        add index FK_68w742sge00vco2cq3jhbvmgx (Deadlines_StartDeadLine_Id), 
        add constraint FK_68w742sge00vco2cq3jhbvmgx 
        foreign key (Deadlines_StartDeadLine_Id) 
        references Task (id)');

    call execute_if_exists('alter table Deadline 
        add index FK_euoohoelbqvv94d8a8rcg8s5n (Deadlines_EndDeadLine_Id), 
        add constraint FK_euoohoelbqvv94d8a8rcg8s5n 
        foreign key (Deadlines_EndDeadLine_Id) 
        references Task (id)');

    call execute_if_exists('alter table Delegation_delegates 
        add index FK_gn7ula51sk55wj1o1m57guqxb (entity_id), 
        add constraint FK_gn7ula51sk55wj1o1m57guqxb 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table Delegation_delegates 
        add index FK_fajq6kossbsqwr3opkrctxei3 (task_id), 
        add constraint FK_fajq6kossbsqwr3opkrctxei3 
        foreign key (task_id) 
        references Task (id)');

    call execute_if_exists('alter table Escalation 
        add index FK_ay2gd4fvl9yaapviyxudwuvfg (Deadline_Escalation_Id), 
        add constraint FK_ay2gd4fvl9yaapviyxudwuvfg 
        foreign key (Deadline_Escalation_Id) 
        references Deadline (id)');

    call execute_if_exists('alter table EventTypes 
        add index FK_nrecj4617iwxlc65ij6m7lsl1 (InstanceId), 
        add constraint FK_nrecj4617iwxlc65ij6m7lsl1 
        foreign key (InstanceId) 
        references ProcessInstanceInfo (InstanceId)');

    call execute_if_exists('alter table I18NText 
        add index FK_k16jpgrh67ti9uedf6konsu1p (Task_Subjects_Id), 
        add constraint FK_k16jpgrh67ti9uedf6konsu1p 
        foreign key (Task_Subjects_Id) 
        references Task (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_fd9uk6hemv2dx1ojovo7ms3vp (Task_Names_Id), 
        add constraint FK_fd9uk6hemv2dx1ojovo7ms3vp 
        foreign key (Task_Names_Id) 
        references Task (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_4eyfp69ucrron2hr7qx4np2fp (Task_Descriptions_Id), 
        add constraint FK_4eyfp69ucrron2hr7qx4np2fp 
        foreign key (Task_Descriptions_Id) 
        references Task (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_pqarjvvnwfjpeyb87yd7m0bfi (Reassignment_Documentation_Id), 
        add constraint FK_pqarjvvnwfjpeyb87yd7m0bfi 
        foreign key (Reassignment_Documentation_Id) 
        references Reassignment (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_o84rkh69r47ti8uv4eyj7bmo2 (Notification_Subjects_Id), 
        add constraint FK_o84rkh69r47ti8uv4eyj7bmo2 
        foreign key (Notification_Subjects_Id) 
        references Notification (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_g1trxri8w64enudw2t1qahhk5 (Notification_Names_Id), 
        add constraint FK_g1trxri8w64enudw2t1qahhk5 
        foreign key (Notification_Names_Id) 
        references Notification (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_qoce92c70adem3ccb3i7lec8x (Notification_Documentation_Id), 
        add constraint FK_qoce92c70adem3ccb3i7lec8x 
        foreign key (Notification_Documentation_Id) 
        references Notification (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_bw8vmpekejxt1ei2ge26gdsry (Notification_Descriptions_Id), 
        add constraint FK_bw8vmpekejxt1ei2ge26gdsry 
        foreign key (Notification_Descriptions_Id) 
        references Notification (id)');

    call execute_if_exists('alter table I18NText 
        add index FK_21qvifarxsvuxeaw5sxwh473w (Deadline_Documentation_Id), 
        add constraint FK_21qvifarxsvuxeaw5sxwh473w 
        foreign key (Deadline_Documentation_Id) 
        references Deadline (id)');

    call execute_if_exists('alter table Notification 
        add index FK_bdbeml3768go5im41cgfpyso9 (Escalation_Notifications_Id), 
        add constraint FK_bdbeml3768go5im41cgfpyso9 
        foreign key (Escalation_Notifications_Id) 
        references Escalation (id)');

    call execute_if_exists('alter table Notification_BAs 
        add index FK_mfbsnbrhth4rjhqc2ud338s4i (entity_id), 
        add constraint FK_mfbsnbrhth4rjhqc2ud338s4i 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table Notification_BAs 
        add index FK_fc0uuy76t2bvxaxqysoo8xts7 (task_id), 
        add constraint FK_fc0uuy76t2bvxaxqysoo8xts7 
        foreign key (task_id) 
        references Notification (id)');

    call execute_if_exists('alter table Notification_Recipients 
        add index FK_blf9jsrumtrthdaqnpwxt25eu (entity_id), 
        add constraint FK_blf9jsrumtrthdaqnpwxt25eu 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table Notification_Recipients 
        add index FK_3l244pj8sh78vtn9imaymrg47 (task_id), 
        add constraint FK_3l244pj8sh78vtn9imaymrg47 
        foreign key (task_id) 
        references Notification (id)');

    call execute_if_exists('alter table Notification_email_header 
        add constraint UK_25vn3oqfsiwwda26w9uiprrwe unique (emailheaders_id)');

    call execute_if_exists('alter table Notification_email_header 
        add index FK_25vn3oqfsiwwda26w9uiprrwe (emailheaders_id), 
        add constraint FK_25vn3oqfsiwwda26w9uiprrwe 
        foreign key (emailheaders_id) 
        references email_header (id)');

    call execute_if_exists('alter table Notification_email_header 
        add index FK_eth4nvxn21fk1vnju85vkjrai (Notification_id), 
        add constraint FK_eth4nvxn21fk1vnju85vkjrai 
        foreign key (Notification_id) 
        references Notification (id)');

    call execute_if_exists('alter table PeopleAssignments_BAs 
        add index FK_t38xbkrq6cppifnxequhvjsl2 (entity_id), 
        add constraint FK_t38xbkrq6cppifnxequhvjsl2 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table PeopleAssignments_BAs 
        add index FK_omjg5qh7uv8e9bolbaq7hv6oh (task_id), 
        add constraint FK_omjg5qh7uv8e9bolbaq7hv6oh 
        foreign key (task_id) 
        references Task (id)');

    call execute_if_exists('alter table PeopleAssignments_ExclOwners 
        add index FK_pth28a73rj6bxtlfc69kmqo0a (entity_id), 
        add constraint FK_pth28a73rj6bxtlfc69kmqo0a 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table PeopleAssignments_ExclOwners 
        add index FK_b8owuxfrdng050ugpk0pdowa7 (task_id), 
        add constraint FK_b8owuxfrdng050ugpk0pdowa7 
        foreign key (task_id) 
        references Task (id)');

    call execute_if_exists('alter table PeopleAssignments_PotOwners 
        add index FK_tee3ftir7xs6eo3fdvi3xw026 (entity_id), 
        add constraint FK_tee3ftir7xs6eo3fdvi3xw026 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table PeopleAssignments_PotOwners 
        add index FK_4dv2oji7pr35ru0w45trix02x (task_id), 
        add constraint FK_4dv2oji7pr35ru0w45trix02x 
        foreign key (task_id) 
        references Task (id)');

    call execute_if_exists('alter table PeopleAssignments_Recipients 
        add index FK_4g7y3wx6gnokf6vycgpxs83d6 (entity_id), 
        add constraint FK_4g7y3wx6gnokf6vycgpxs83d6 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table PeopleAssignments_Recipients 
        add index FK_enhk831fghf6akjilfn58okl4 (task_id), 
        add constraint FK_enhk831fghf6akjilfn58okl4 
        foreign key (task_id) 
        references Task (id)');

    call execute_if_exists('alter table PeopleAssignments_Stakeholders 
        add index FK_met63inaep6cq4ofb3nnxi4tm (entity_id), 
        add constraint FK_met63inaep6cq4ofb3nnxi4tm 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table PeopleAssignments_Stakeholders 
        add index FK_4bh3ay74x6ql9usunubttfdf1 (task_id), 
        add constraint FK_4bh3ay74x6ql9usunubttfdf1 
        foreign key (task_id) 
        references Task (id)');

    call execute_if_exists('alter table Reassignment 
        add index FK_pnpeue9hs6kx2ep0sp16b6kfd (Escalation_Reassignments_Id), 
        add constraint FK_pnpeue9hs6kx2ep0sp16b6kfd 
        foreign key (Escalation_Reassignments_Id) 
        references Escalation (id)');

    call execute_if_exists('alter table Reassignment_potentialOwners 
        add index FK_8frl6la7tgparlnukhp8xmody (entity_id), 
        add constraint FK_8frl6la7tgparlnukhp8xmody 
        foreign key (entity_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table Reassignment_potentialOwners 
        add index FK_qbega5ncu6b9yigwlw55aeijn (task_id), 
        add constraint FK_qbega5ncu6b9yigwlw55aeijn 
        foreign key (task_id) 
        references Reassignment (id)');

    call execute_if_exists('alter table Task 
        add index FK_7hos7h1ft5wygyru9vm2mtp6b (peopl_assign_taskinitiator_id), 
        add constraint FK_7hos7h1ft5wygyru9vm2mtp6b 
        foreign key (peopl_assign_taskinitiator_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table Task 
        add index FK_iu0slqdkjbb9mvikrns8mvqcg (taskdata_actualowner_id), 
        add constraint FK_iu0slqdkjbb9mvikrns8mvqcg 
        foreign key (taskdata_actualowner_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table Task 
        add index FK_tek6betmy2fl0bnwrsx9a4fi9 (taskdata_createdby_id), 
        add constraint FK_tek6betmy2fl0bnwrsx9a4fi9 
        foreign key (taskdata_createdby_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table task_comment 
        add index FK_fencp0rt8gae730n7621vqjre (addedby_id), 
        add constraint FK_fencp0rt8gae730n7621vqjre 
        foreign key (addedby_id) 
        references OrganizationalEntity (id)');

    call execute_if_exists('alter table task_comment 
        add index FK_1ws9jdmhtey6mxu7jb0r0ufvs (TaskData_Comments_Id), 
        add constraint FK_1ws9jdmhtey6mxu7jb0r0ufvs 
        foreign key (TaskData_Comments_Id) 
        references Task (id)');
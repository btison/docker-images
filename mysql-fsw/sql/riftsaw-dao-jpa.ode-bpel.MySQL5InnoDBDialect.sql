
    create table if not exists BPAF_EVENT (
        EID bigint not null auto_increment,
        ACTIVITY_DEFINITION_ID varchar(255),
        ACTIVITY_INSTANCE_ID varchar(255),
        ACTIVITY_NAME varchar(255),
        CURRENT_STATE varchar(255),
        PREVIOUS_STATE varchar(255),
        PROCESS_DEFINITION_ID varchar(255),
        PROCESS_INSTANCE_ID varchar(255),
        PROCESS_NAME varchar(255),
        SERVER_ID varchar(255),
        TIMESTAMP bigint,
        primary key (EID)
    ) ENGINE=InnoDB;

    create table if not exists BPAF_EVENT_DATA (
        TID bigint not null auto_increment,
        NAME varchar(255),
        VALUE longtext,
        EVENT_ID bigint,
        primary key (TID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_ACTIVITY_RECOVERY (
        ID bigint not null auto_increment,
        ACTIONS varchar(255),
        ACTIVITY_ID bigint,
        CHANNEL varchar(255),
        DATE_TIME datetime,
        DETAILS longtext,
        INSTANCE_ID bigint,
        REASON varchar(255),
        RETRIES integer,
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_CORRELATION_SET (
        CORRELATION_SET_ID bigint not null auto_increment,
        CORRELATION_KEY varchar(255),
        NAME varchar(255),
        SCOPE_ID bigint,
        primary key (CORRELATION_SET_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_CORRELATOR (
        CORRELATOR_ID bigint not null auto_increment,
        CORRELATOR_KEY varchar(255),
        PROC_ID bigint,
        primary key (CORRELATOR_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_CORSET_PROP (
        ID bigint not null auto_increment,
        CORRSET_ID bigint,
        PROP_KEY varchar(255),
        PROP_VALUE varchar(255),
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_EVENT (
        EVENT_ID bigint not null auto_increment,
        DETAIL varchar(255),
        DATA longblob,
        SCOPE_ID bigint,
        TSTAMP datetime,
        TYPE varchar(255),
        INSTANCE_ID bigint,
        PROCESS_ID bigint,
        primary key (EVENT_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_FAULT (
        FAULT_ID bigint not null auto_increment,
        ACTIVITY_ID integer,
        DATA longtext,
        MESSAGE longtext,
        LINE_NUMBER integer,
        NAME varchar(255),
        primary key (FAULT_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_MESSAGE (
        MESSAGE_ID bigint not null auto_increment,
        DATA longtext,
        HEADER longtext,
        TYPE varchar(255),
        MESSAGE_EXCHANGE_ID varchar(255),
        primary key (MESSAGE_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_MESSAGE_EXCHANGE (
        MESSAGE_EXCHANGE_ID varchar(255) not null,
        CALLEE varchar(255),
        CHANNEL varchar(255),
        CORRELATION_ID varchar(255),
        CORRELATION_KEYS varchar(255),
        CORRELATION_STATUS varchar(255),
        CREATE_TIME datetime,
        DIRECTION char(1),
        EPR longtext,
        FAULT varchar(255),
        FAULT_EXPLANATION varchar(255),
        OPERATION varchar(255),
        PARTNER_LINK_MODEL_ID integer,
        PATTERN varchar(255),
        PIPED_ID varchar(255),
        PORT_TYPE varchar(255),
        PROPAGATE_TRANS boolean,
        STATUS varchar(255),
        SUBSCRIBER_COUNT integer,
        CORR_ID bigint,
        PARTNER_LINK_ID bigint,
        PROCESS_ID bigint,
        PROCESS_INSTANCE_ID bigint,
        REQUEST_MESSAGE_ID bigint,
        RESPONSE_MESSAGE_ID bigint,
        primary key (MESSAGE_EXCHANGE_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_MESSAGE_ROUTE (
        MESSAGE_ROUTE_ID bigint not null auto_increment,
        CORRELATION_KEY varchar(255),
        GROUP_ID varchar(255),
        ROUTE_INDEX integer,
        PROCESS_INSTANCE_ID bigint,
        ROUTE_POLICY varchar(16),
        CORR_ID bigint,
        primary key (MESSAGE_ROUTE_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_MEX_PROP (
        ID bigint not null auto_increment,
        MEX_ID varchar(255),
        PROP_KEY varchar(255),
        PROP_VALUE varchar(2000),
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_PARTNER_LINK (
        PARTNER_LINK_ID bigint not null auto_increment,
        MY_EPR longtext,
        MY_ROLE_NAME varchar(255),
        MY_ROLE_SERVICE_NAME varchar(255),
        MY_SESSION_ID varchar(255),
        PARTNER_EPR longtext,
        PARTNER_LINK_MODEL_ID integer,
        PARTNER_LINK_NAME varchar(255),
        PARTNER_ROLE_NAME varchar(255),
        PARTNER_SESSION_ID varchar(255),
        SCOPE_ID bigint,
        primary key (PARTNER_LINK_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_PROCESS (
        ID bigint not null auto_increment,
        GUID varchar(255),
        PROCESS_ID varchar(255),
        PROCESS_TYPE varchar(255),
        VERSION bigint,
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_PROCESS_INSTANCE (
        ID bigint not null auto_increment,
        DATE_CREATED datetime,
        EXECUTION_STATE longblob,
        FAULT_ID bigint,
        LAST_ACTIVE_TIME datetime,
        LAST_RECOVERY_DATE datetime,
        PREVIOUS_STATE smallint,
        SEQUENCE bigint,
        INSTANCE_STATE smallint,
        INSTANTIATING_CORRELATOR_ID bigint,
        PROCESS_ID bigint,
        ROOT_SCOPE_ID bigint,
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_SCOPE (
        SCOPE_ID bigint not null auto_increment,
        MODEL_ID integer,
        SCOPE_NAME varchar(255),
        SCOPE_STATE varchar(255),
        PARENT_SCOPE_ID bigint,
        PROCESS_INSTANCE_ID bigint,
        primary key (SCOPE_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_XML_DATA (
        XML_DATA_ID bigint not null auto_increment,
        DATA longtext,
        IS_SIMPLE_TYPE boolean,
        NAME varchar(255),
        SCOPE_ID bigint,
        primary key (XML_DATA_ID)
    ) ENGINE=InnoDB;

    create table if not exists BPEL_XML_DATA_PROP (
        ID bigint not null auto_increment,
        XML_DATA_ID bigint,
        PROP_KEY varchar(255),
        PROP_VALUE varchar(255),
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists ODE_JOB (
        jobid varchar(64) not null,
        channel varchar(255),
        correlationKeySet varchar(255),
        correlatorId varchar(255),
        detailsExt longblob,
        inMem boolean,
        instanceId bigint,
        mexId varchar(255),
        nodeid varchar(64),
        processId varchar(255),
        retryCount integer,
        scheduled boolean not null,
        ts bigint not null,
        transacted boolean not null,
        type varchar(255),
        primary key (jobid)
    ) ENGINE=InnoDB;

    create table if not exists STORE_DU (
        NAME varchar(255) not null,
        DEPLOYDT datetime,
        DEPLOYER varchar(255),
        DIR varchar(255),
        primary key (NAME)
    ) ENGINE=InnoDB;

    create table if not exists STORE_PROCESS (
        PID varchar(255) not null,
        STATE varchar(255),
        TYPE varchar(255),
        VERSION bigint,
        DU varchar(255),
        primary key (PID)
    ) ENGINE=InnoDB;

    create table if not exists STORE_PROCESS_PROP (
        ID bigint not null auto_increment,
        PROP_KEY varchar(255),
        PROP_VAL varchar(255),
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists STORE_PROC_TO_PROP (
        STORE_PROCESS_PID varchar(255) not null,
        STORE_PROPERTY_ID bigint not null,
        primary key (STORE_PROCESS_PID, STORE_PROPERTY_ID)
    ) ENGINE=InnoDB;

    create table if not exists STORE_VERSIONS (
        ID bigint not null auto_increment,
        VERSION bigint,
        primary key (ID)
    ) ENGINE=InnoDB;

    call execute_if_exists('alter table BPAF_EVENT_DATA 
        add index FK_5dx9wlbxkeho97gui4la0vjye (EVENT_ID), 
        add constraint FK_5dx9wlbxkeho97gui4la0vjye 
        foreign key (EVENT_ID) 
        references BPAF_EVENT (EID)');

    call execute_if_exists('alter table BPEL_ACTIVITY_RECOVERY 
        add index FK_5iwucbr1yngxjs16sxeej3xpp (INSTANCE_ID), 
        add constraint FK_5iwucbr1yngxjs16sxeej3xpp 
        foreign key (INSTANCE_ID) 
        references BPEL_PROCESS_INSTANCE (ID)');

    call execute_if_exists('alter table BPEL_CORRELATION_SET 
        add index FK_j1vdkxghmf62wsykum7ut0mjp (SCOPE_ID), 
        add constraint FK_j1vdkxghmf62wsykum7ut0mjp 
        foreign key (SCOPE_ID) 
        references BPEL_SCOPE (SCOPE_ID)');

    call execute_if_exists('alter table BPEL_CORRELATOR 
        add index FK_6sqr3hmuqssl6v7en9extt6nb (PROC_ID), 
        add constraint FK_6sqr3hmuqssl6v7en9extt6nb 
        foreign key (PROC_ID) 
        references BPEL_PROCESS (ID)');

    call execute_if_exists('alter table BPEL_CORSET_PROP 
        add index FK_6vmj2n3pf8el6xupevpjpw0q5 (CORRSET_ID), 
        add constraint FK_6vmj2n3pf8el6xupevpjpw0q5 
        foreign key (CORRSET_ID) 
        references BPEL_CORRELATION_SET (CORRELATION_SET_ID)');

    call execute_if_exists('alter table BPEL_EVENT 
        add index FK_on6qt1pmhmhq302bvn0afqrib (INSTANCE_ID), 
        add constraint FK_on6qt1pmhmhq302bvn0afqrib 
        foreign key (INSTANCE_ID) 
        references BPEL_PROCESS_INSTANCE (ID)');

    call execute_if_exists('alter table BPEL_EVENT 
        add index FK_3i4chalwvtcsxnb3kitlk008i (PROCESS_ID), 
        add constraint FK_3i4chalwvtcsxnb3kitlk008i 
        foreign key (PROCESS_ID) 
        references BPEL_PROCESS (ID)');

    call execute_if_exists('alter table BPEL_MESSAGE 
        add index FK_t7okesqhwuldkv1hh6gbqf2ou (MESSAGE_EXCHANGE_ID), 
        add constraint FK_t7okesqhwuldkv1hh6gbqf2ou 
        foreign key (MESSAGE_EXCHANGE_ID) 
        references BPEL_MESSAGE_EXCHANGE (MESSAGE_EXCHANGE_ID)');

    call execute_if_exists('alter table BPEL_MESSAGE_EXCHANGE 
        add index FK_h7khyrytsirwd8wab4u46m2n8 (CORR_ID), 
        add constraint FK_h7khyrytsirwd8wab4u46m2n8 
        foreign key (CORR_ID) 
        references BPEL_CORRELATOR (CORRELATOR_ID)');

    call execute_if_exists('alter table BPEL_MESSAGE_EXCHANGE 
        add index FK_uonx6oawfknxho8jrf3rfk5c (PARTNER_LINK_ID), 
        add constraint FK_uonx6oawfknxho8jrf3rfk5c 
        foreign key (PARTNER_LINK_ID) 
        references BPEL_PARTNER_LINK (PARTNER_LINK_ID)');

    call execute_if_exists('alter table BPEL_MESSAGE_EXCHANGE 
        add index FK_gb2u3yldxdoo1cwm0r4ueumks (PROCESS_ID), 
        add constraint FK_gb2u3yldxdoo1cwm0r4ueumks 
        foreign key (PROCESS_ID) 
        references BPEL_PROCESS (ID)');

    call execute_if_exists('alter table BPEL_MESSAGE_ROUTE 
        add index FK_c7spgx5vfvekg032033rpqdbk (CORR_ID), 
        add constraint FK_c7spgx5vfvekg032033rpqdbk 
        foreign key (CORR_ID) 
        references BPEL_CORRELATOR (CORRELATOR_ID)');

    call execute_if_exists('alter table BPEL_MESSAGE_ROUTE 
        add index FK_fxmbqc9xnjklj0k4bn1e2l34x (PROCESS_INSTANCE_ID), 
        add constraint FK_fxmbqc9xnjklj0k4bn1e2l34x 
        foreign key (PROCESS_INSTANCE_ID) 
        references BPEL_PROCESS_INSTANCE (ID)');

    call execute_if_exists('alter table BPEL_MEX_PROP 
        add index FK_4hprt848lqhnc8pjdxhslqy53 (MEX_ID), 
        add constraint FK_4hprt848lqhnc8pjdxhslqy53 
        foreign key (MEX_ID) 
        references BPEL_MESSAGE_EXCHANGE (MESSAGE_EXCHANGE_ID)');

    call execute_if_exists('alter table BPEL_PARTNER_LINK 
        add index FK_n42xwpib34r1o4j3gum2o7teo (SCOPE_ID), 
        add constraint FK_n42xwpib34r1o4j3gum2o7teo 
        foreign key (SCOPE_ID) 
        references BPEL_SCOPE (SCOPE_ID)');

    call execute_if_exists('alter table BPEL_PROCESS_INSTANCE 
        add index FK_cbaftcdg3olwu6c1hb9uiysh8 (INSTANTIATING_CORRELATOR_ID), 
        add constraint FK_cbaftcdg3olwu6c1hb9uiysh8 
        foreign key (INSTANTIATING_CORRELATOR_ID) 
        references BPEL_CORRELATOR (CORRELATOR_ID)');

    call execute_if_exists('alter table BPEL_PROCESS_INSTANCE 
        add index FK_s6umxoyr597vbkk95ff9uwx8 (PROCESS_ID), 
        add constraint FK_s6umxoyr597vbkk95ff9uwx8 
        foreign key (PROCESS_ID) 
        references BPEL_PROCESS (ID)');

    call execute_if_exists('alter table BPEL_SCOPE 
        add index FK_nuormejxj2iyfxm4yny8g2msh (PROCESS_INSTANCE_ID), 
        add constraint FK_nuormejxj2iyfxm4yny8g2msh 
        foreign key (PROCESS_INSTANCE_ID) 
        references BPEL_PROCESS_INSTANCE (ID)');

    call execute_if_exists('alter table BPEL_XML_DATA 
        add index FK_g0pgad8e5x63j502w4ps9ysnh (SCOPE_ID), 
        add constraint FK_g0pgad8e5x63j502w4ps9ysnh 
        foreign key (SCOPE_ID) 
        references BPEL_SCOPE (SCOPE_ID)');

    call execute_if_exists('alter table BPEL_XML_DATA_PROP 
        add index FK_5pv5xml1vgquncql9irej95k7 (XML_DATA_ID), 
        add constraint FK_5pv5xml1vgquncql9irej95k7 
        foreign key (XML_DATA_ID) 
        references BPEL_XML_DATA (XML_DATA_ID)');

    call execute_if_exists('alter table STORE_PROCESS 
        add index FK_c8haf42aukvqr2udrtpyi3kdb (DU), 
        add constraint FK_c8haf42aukvqr2udrtpyi3kdb 
        foreign key (DU) 
        references STORE_DU (NAME)');

    call execute_if_exists('alter table STORE_PROC_TO_PROP 
        add constraint UK_ld9y5wtckspqw9us9gfeokf6a unique (STORE_PROPERTY_ID)');

    call execute_if_exists('alter table STORE_PROC_TO_PROP 
        add index FK_ld9y5wtckspqw9us9gfeokf6a (STORE_PROPERTY_ID), 
        add constraint FK_ld9y5wtckspqw9us9gfeokf6a 
        foreign key (STORE_PROPERTY_ID) 
        references STORE_PROCESS_PROP (ID)');

    call execute_if_exists('alter table STORE_PROC_TO_PROP 
        add index FK_t19b3gjvbvqke3hh5mcdr2dwl (STORE_PROCESS_PID), 
        add constraint FK_t19b3gjvbvqke3hh5mcdr2dwl 
        foreign key (STORE_PROCESS_PID) 
        references STORE_PROCESS (PID)');
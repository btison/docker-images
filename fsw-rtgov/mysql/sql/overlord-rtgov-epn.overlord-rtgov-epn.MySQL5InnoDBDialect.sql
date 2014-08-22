
    create table if not exists RTGOV_ACTIVITIES (
        activityType varchar(31) not null,
        unitId varchar(255) not null,
        unitIndex integer not null,
        principal varchar(255),
        tstamp bigint,
        customType varchar(255),
        logLevel integer,
        message varchar(255),
        instanceId varchar(255),
        processType varchar(255),
        status integer,
        version varchar(255),
        variableName varchar(255),
        variableType varchar(255),
        variableValue varchar(255),
        content longtext,
        messageType varchar(255),
        destination varchar(255),
        fault varchar(255),
        interface varchar(255),
        operation varchar(255),
        serviceType varchar(255),
        replyToId varchar(255),
        primary key (unitId, unitIndex)
    ) ENGINE=InnoDB;

    create table if not exists RTGOV_ACTIVITY_CONTEXT (
        unitId varchar(255) not null,
        unitIndex integer not null,
        timeframe bigint,
        contextType varchar(255),
        value varchar(255)
    ) ENGINE=InnoDB;

    create table if not exists RTGOV_ACTIVITY_PROPERTIES (
        unitId varchar(255) not null,
        unitIndex integer not null,
        value varchar(255),
        name varchar(255) not null,
        primary key (unitId, unitIndex, name)
    ) ENGINE=InnoDB;

    create table if not exists RTGOV_ACTIVITY_UNITS (
        id varchar(255) not null,
        host varchar(255),
        node varchar(255),
        principal varchar(255),
        thread varchar(255),
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists RTGOV_SITUATIONS (
        id varchar(255) not null,
        description longtext,
        severity integer,
        subject varchar(255),
        tstamp bigint,
        situationType varchar(255),
        primary key (id)
    ) ENGINE=InnoDB;

    create table if not exists RTGOV_SITUATION_ACTIVITY_TYPES (
        Situation_id varchar(255) not null,
        unitId varchar(255),
        unitIndex integer not null,
        primary key (Situation_id, unitIndex)
    ) ENGINE=InnoDB;

    create table if not exists RTGOV_SITUATION_CONTEXT (
        Situation_id varchar(255) not null,
        timeframe bigint,
        contextType varchar(255),
        value varchar(255)
    ) ENGINE=InnoDB;

    create table if not exists RTGOV_SITUATION_PROPERTIES (
        id varchar(255) not null,
        value varchar(255),
        name varchar(255) not null,
        primary key (id, name)
    ) ENGINE=InnoDB;

    call execute_if_exists('alter table RTGOV_ACTIVITIES 
        add index FK_qkn2182qh2hf52txyugoloqaq (unitId), 
        add constraint FK_qkn2182qh2hf52txyugoloqaq 
        foreign key (unitId) 
        references RTGOV_ACTIVITY_UNITS (id)');

    call execute_if_exists('alter table RTGOV_ACTIVITY_CONTEXT 
        add index FK_taqus05muupkc8xuuyig97lx7 (unitId, unitIndex), 
        add constraint FK_taqus05muupkc8xuuyig97lx7 
        foreign key (unitId, unitIndex) 
        references RTGOV_ACTIVITIES (unitId, unitIndex)');

    call execute_if_exists('alter table RTGOV_ACTIVITY_PROPERTIES 
        add index FK_c5src0indd1kbiljcs7ruf2rc (unitId, unitIndex), 
        add constraint FK_c5src0indd1kbiljcs7ruf2rc 
        foreign key (unitId, unitIndex) 
        references RTGOV_ACTIVITIES (unitId, unitIndex)');

    call execute_if_exists('alter table RTGOV_SITUATION_ACTIVITY_TYPES 
        add index FK_l3yoqst9iu0euiw0vo2b5t5yu (Situation_id), 
        add constraint FK_l3yoqst9iu0euiw0vo2b5t5yu 
        foreign key (Situation_id) 
        references RTGOV_SITUATIONS (id)');

    call execute_if_exists('alter table RTGOV_SITUATION_CONTEXT 
        add index FK_b08bon7ya4r67qlm24alhqdpg (Situation_id), 
        add constraint FK_b08bon7ya4r67qlm24alhqdpg 
        foreign key (Situation_id) 
        references RTGOV_SITUATIONS (id)');

    call execute_if_exists('alter table RTGOV_SITUATION_PROPERTIES 
        add index FK_js9tml3lmnlrl38etv7mouwox (id), 
        add constraint FK_js9tml3lmnlrl38etv7mouwox 
        foreign key (id) 
        references RTGOV_SITUATIONS (id)');
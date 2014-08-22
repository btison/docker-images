
    create table if not exists GS_APP_DATA (
        ID bigint not null auto_increment,
        APP_URL varchar(255),
        USER_ID bigint,
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists GS_GADGET (
        GAGET_ID bigint not null auto_increment,
        GADGET_AUTHOR varchar(255),
        GADGET_AUTHOR_EMAIL varchar(255),
        GADGET_DESCRIPTION varchar(255),
        GADGET_GROUP tinyblob,
        GADGET_SCREENSHOT_URL varchar(255),
        GADGET_THUMBNAIL_URL varchar(255),
        GADGET_TITLE varchar(255),
        GADGET_TITLE_URL varchar(255),
        GADGET_TYPE varchar(255),
        GADGET_URL varchar(255),
        primary key (GAGET_ID)
    ) ENGINE=InnoDB;

    create table if not exists GS_GROUP (
        GROUP_ID bigint not null auto_increment,
        GROUP_DESC varchar(255),
        GROUP_NAME varchar(255),
        primary key (GROUP_ID)
    ) ENGINE=InnoDB;

    create table if not exists GS_PAGE (
        PAGE_ID bigint not null auto_increment,
        PAGE_COLUMNS bigint,
        PAGE_NAME varchar(255),
        PAGE_ORDER bigint,
        PAGE_USER bigint,
        primary key (PAGE_ID)
    ) ENGINE=InnoDB;

    create table if not exists GS_USER (
        ID bigint not null auto_increment,
        CURR_PAGE_ID bigint,
        DISPLAY_NAME varchar(255),
        EMAIL varchar(255),
        NAME varchar(255),
        USER_ROLE varchar(255),
        primary key (ID)
    ) ENGINE=InnoDB;

    create table if not exists GS_USER_GROUP (
        USER_ID bigint not null,
        GROUP_ID bigint not null
    ) ENGINE=InnoDB;

    create table if not exists GS_WIDGET (
        WIDGET_ID bigint not null auto_increment,
        WIDGET_URL varchar(255),
        WIDGET_NAME varchar(255),
        WIDGET_ORDER bigint,
        page_PAGE_ID bigint,
        primary key (WIDGET_ID)
    ) ENGINE=InnoDB;

    create table if not exists GS_WIDGET_PREF (
        WIDGET_PREF_ID bigint not null auto_increment,
        WIDGET_PREF_NAME varchar(255),
        WIDGET_PREF_VALUE varchar(255),
        widget_WIDGET_ID bigint,
        primary key (WIDGET_PREF_ID)
    ) ENGINE=InnoDB;

    call execute_if_exists('alter table GS_PAGE 
        add index FK_5j5yf04wju6wn9q6j0sli31wq (PAGE_USER), 
        add constraint FK_5j5yf04wju6wn9q6j0sli31wq 
        foreign key (PAGE_USER) 
        references GS_USER (ID)');

    call execute_if_exists('alter table GS_USER_GROUP 
        add index FK_mgiqrspnmywwtgpfuoxvxo1bb (GROUP_ID), 
        add constraint FK_mgiqrspnmywwtgpfuoxvxo1bb 
        foreign key (GROUP_ID) 
        references GS_GROUP (GROUP_ID)');

    call execute_if_exists('alter table GS_USER_GROUP 
        add index FK_c4slaed8sqe7jpu080d9fhslh (USER_ID), 
        add constraint FK_c4slaed8sqe7jpu080d9fhslh 
        foreign key (USER_ID) 
        references GS_USER (ID)');

    call execute_if_exists('alter table GS_WIDGET 
        add index FK_itursfkumpygn547bnx4jp4cl (page_PAGE_ID), 
        add constraint FK_itursfkumpygn547bnx4jp4cl 
        foreign key (page_PAGE_ID) 
        references GS_PAGE (PAGE_ID)');

    call execute_if_exists('alter table GS_WIDGET_PREF 
        add index FK_152vlr5pyu65tpe6jadivbj4 (widget_WIDGET_ID), 
        add constraint FK_152vlr5pyu65tpe6jadivbj4 
        foreign key (widget_WIDGET_ID) 
        references GS_WIDGET (WIDGET_ID)');
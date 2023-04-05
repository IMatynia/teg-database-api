drop table quiz_tags;
drop table article_tags;
drop table quiz_questions;
drop table articles;
drop table quizes;
drop table qna_comments;
drop table authors;

create or replace table authors
(
    author_id int               not null auto_increment primary key,
    full_name text charset utf8 not null,
    unique (full_name(15)),
    picture   text,
    info      text
);

create or replace table articles
(
    article_id     int                       not null auto_increment primary key,
    sname          tinytext charset utf8     not null,
    unique (sname(20)),
    author_id      int                       not null,
    constraint fk_art_author_id foreign key (author_id) references authors (author_id) on delete cascade on update cascade,
    date_published timestamp                 not null default current_timestamp,
    title          varchar(512) charset utf8 not null,
    unique (title(64)),
    thumbnail      text,
    summary        text charset utf8         not null,
    content        longtext charset utf8     not null
);

create or replace view articles_w_authors as
select articles.article_id,
       sname,
       date_published,
       title,
       thumbnail,
       summary,
       content,
       a.full_name author
from articles
         inner join authors a on articles.author_id = a.author_id;

create or replace table quizes
(
    quiz_id        int                       not null auto_increment primary key,
    sname          tinytext charset utf8     not null unique,
    author_id      int                       not null,
    constraint fk_qui_author_id foreign key (author_id) references authors (author_id) on delete cascade on update cascade,
    date_published timestamp                 not null default current_timestamp,
    title          varchar(512) charset utf8 not null unique,
    thumbnail      text,
    description    text charset utf8
);

create or replace view quizes_w_authors as
select quiz_id, sname, date_published, title, thumbnail, description, a.full_name
from quizes
         inner join authors a on quizes.author_id = a.author_id;

create or replace table quiz_questions
(
    question_id int   not null auto_increment primary key,
    quiz_id     int   not null,
    constraint fk_qq_quiz_id foreign key (quiz_id) references quizes (quiz_id) on delete cascade on update cascade,
    pos         int   not null,
    type        int   not null,
    ans_value   float not null,
    question    text  not null,
    image       text
);

create or replace table tags
(
    tag_id      int                   not null auto_increment primary key,
    name        tinytext charset utf8 not null unique,
    thumbnail   text,
    description text charset utf8
);

create or replace table article_tags
(
    id         int not null auto_increment primary key,
    article_id int not null,
    constraint fk_at_article_id foreign key (article_id) references articles (article_id) on delete cascade on update cascade,
    tag_id     int not null,
    constraint fk_at_tag_id foreign key (tag_id) references tags (tag_id) on delete cascade on update cascade,
    constraint u_at_unique unique (article_id, tag_id)
);

create or replace table quiz_tags
(
    id      int not null auto_increment primary key,
    quiz_id int not null,
    constraint fk_qt_quiz_id foreign key (quiz_id) references quizes (quiz_id) on delete cascade on update cascade,
    tag_id  int not null,
    constraint fk_qt_tag_id foreign key (tag_id) references tags (tag_id) on delete cascade on update cascade,
    constraint u_qt_unique unique (quiz_id, tag_id)
);

create or replace table qna_comments
(
    id             int                       not null auto_increment primary key,
    date_published timestamp                 not null default current_timestamp,
    ip_hash        char(32)                  not null,
    author_id      int                                default null,
    constraint fr_c_author_id foreign key (author_id) references authors (author_id) on delete cascade on update cascade,
    visible        bool                      not null default FALSE,
    parent         int                                default null,
    constraint fk_c_parent_id foreign key (parent) references qna_comments (id) on delete cascade on update cascade,
    content        varchar(512) charset utf8 not null
);

create or replace table api_keys
(
    api_key         char(32)     not null primary key,
    access_level    int unsigned not null default 1000,
    quota_remaining bigint       not null default 0,
    expiration_date timestamp    not null default (current_timestamp + interval 1 month)
);

create or replace table ads
(
    ad_id        int  not null auto_increment primary key,
    redirect_url text not null,
    image        text not null,
    hint         text
);
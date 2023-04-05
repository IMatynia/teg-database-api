delimiter //
create or replace function generate_api_key(p_gen_text text, p_quota int, p_expiration_date timestamp)
    returns tinytext
    modifies sql data
    comment 'Creates a new api key with some expiration date and quota'
begin
    declare v_gen_word_md5 tinytext;
    set v_gen_word_md5 = md5(p_gen_text);
    insert into teg_local.api_keys (api_key, quota_remaining, expiration_date)
    values (v_gen_word_md5, p_quota, p_expiration_date);
    return (v_gen_word_md5);
end //

create or replace function use_api_key(p_api_key tinytext)
    returns boolean
    modifies sql data reads sql data
    comment 'If api key is valid, decrements its quota by 1 and returns TRUE, else returns FALSE'
begin
    declare v_rem_quota int;
    declare v_expir_date timestamp;

    select expiration_date, quota_remaining into v_expir_date, v_rem_quota from api_keys where api_key = p_api_key;
    if v_rem_quota > 0 and v_expir_date > current_timestamp then
        update api_keys set quota_remaining = v_rem_quota - 1 where api_key = p_api_key;
        return TRUE;
    elseif v_rem_quota = 0 then
        delete from api_keys where api_key = p_api_key;
        return (FALSE);
    else
        return (FALSE);
    end if;
end
//

create or replace procedure add_article_tag(p_article_sname text, p_tag_name text)
    MODIFIES SQL DATA reads sql data
begin
    declare v_article_id int;
    declare v_tag_id int;

    set v_article_id = (select article_id
                        from articles
                        where sname = p_article_sname);
    set v_tag_id = (select tag_id
                    from tags
                    where name = p_tag_name);

    insert into article_tags
    values (null, v_article_id, v_tag_id);
end //

create or replace procedure add_article(p_sname text, p_author text, p_title text, p_thumbnail text, p_summary text,
                                        p_content longtext)
    MODIFIES SQL DATA reads sql data
begin
    declare v_author_id int;

    select author_id
    into v_author_id
    from authors
    where full_name = p_author;

    insert into articles (sname, author_id, title, thumbnail, summary, content)
    values (p_sname, v_author_id, p_title, p_thumbnail, p_summary, p_content);
end //

create or replace procedure add_quiz(p_sname tinytext, p_author text, p_title text, p_thumbnail text,
                                     p_description text)
    MODIFIES SQL DATA reads sql data
begin
    declare v_author_id int;

    select author_id
    into v_author_id
    from authors
    where full_name = p_author;

    insert into quizes values (default, p_sname, v_author_id, default, p_title, p_thumbnail, p_description);
end //

create or replace procedure add_question(p_sname tinytext, p_pos int, p_type int, p_ans_value float, p_question text,
                                         p_image text)
    MODIFIES SQL DATA reads sql data
begin
    declare v_quiz_id int;
    select quiz_id into v_quiz_id from quizes where sname = p_sname;
    insert into quiz_questions values (default, v_quiz_id, p_pos, p_type, p_ans_value, p_question, p_image);
end //

create or replace procedure add_quiz_tag(p_quiz_sname text, p_tag_name text)
    MODIFIES SQL DATA reads sql data
begin
    declare v_quiz_id int;
    declare v_tag_id int;

    set v_quiz_id = (select quiz_id
                     from quizes
                     where sname = p_quiz_sname);
    set v_tag_id = (select tag_id
                    from tags
                    where name = p_tag_name);

    insert into quiz_tags
    values (null, v_quiz_id, v_tag_id);
end //

delimiter ;
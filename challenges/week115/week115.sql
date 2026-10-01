-- create database frosty_friday;
-- create schema week_115;


/*
# Week 115 - SQL & Query Techniques

We all have tools at our disposal that are very powerful but go unused for a long time. A tool that once we stop using it, we start losing our ability to understand how it worked.

The tool somewhere near the top of our list that follows that reference is Regular Expressions (or RegEx for short). To give everyone the opportunity to stretch those muscles again, we've got 4 RegEx challenge for you to tackle!

私たちには、非常に強力でありながら、長い間使われずに放置されている道具が誰にでもあるものです。一度使いなくなると、その仕組みを理解する能力が徐々に失われていくような道具です。

その参考資料に続く、私たちのリストの上位に位置するツールが「正規表現（略してRegEx）」です。皆さんに再びその腕を磨く機会を提供するため、4つの正規表現チャレンジをご用意しました！
*/



/*
Challenge 1: Validate Complex Email Addresses

Objective: Create a query that uses REGEXP_LIKE to validate complex email addresses.

Pattern Requirements:

- Must begin with alphanumeric characters (a-z, A-Z, 0-9).
- May include dots (.) or hyphens (-), but these cannot be at the start or end.
- The domain should have two parts separated by a dot: the domain name and a valid top-level domain (TLD).
- TLD must be 2 to 6 letters long.

課題 1：複雑なメールアドレスの検証

目的：REGEXP_LIKE を使用して複雑なメールアドレスを検証するクエリを作成する。

パターンの要件：

- 先頭が英数字（a-z、A-Z、0-9）でなければならない。
- ドット（.）やハイフン（-）を含んでもよいが、これらは先頭や末尾に配置してはならない。
- ドメインは、ドットで区切られた 2 つの部分（ドメイン名と有効なトップレベルドメイン（TLD））で構成されている必要があります。
- TLD は 2 文字から 6 文字でなければなりません。
*/

-- Start-up Code
CREATE TABLE users (
    user_id INT AUTOINCREMENT,
    email VARCHAR
);

INSERT INTO users (email) 
VALUES
    ('john.doe@example.com'),
    ('invalid-email@.com'),
    ('alice_smith@sub-domain.co.uk'),
    ('bob@domain.com'),
    ('user@invalid_domain@com');

-- ついでに追加の値も入れておこう
INSERT INTO users (email) 
VALUES
    ('.john.doe@example.com'),
    ('-john.doe@example.com'),
    ('john.doe@example.com-'),
    ('john.doe@example.com.');


/*
##########
# 解説
##########

Snowflakeの正規表現の関数は POSIX ERE （拡張正規表現）構文のほとんどをサポートしている。

今回はObjectiveにも書かれているとおり REGEXP_LIKE 関数を利用するが、RLIKEでも可なので、別海としてそちらも利用してみる。

REGEXP_LIKE 関数は引数に検索対象の文字列、一致するパターン、オプションのパラメータを渡す。
戻り値は一致するかどうかのbooleanである。

パラメータは以下の通りでデフォルトは c である。今回はcのままでOK。

| パラメーター | 説明 |
| --- | --- |
| c | 大文字と小文字を区別する一致 |
| i | 大文字と小文字を区別しない一致 |
| m | 複数行モード |
| e | 部分一致を抽出 |
| s | 単一行モード POSIX ワイルドカード文字 . 一致 \n |

実装する上で気をつけるのは以下

- 基本的な構文はドキュメントにもリンクが置かれているwikipediaを参照する
  https://en.wikipedia.org/wiki/Regular_expression#POSIX_basic_and_extended
- .* が任意の文字列を表現できるので埋めるのに便利
- エスケープは\\を利用する（重ねないといけない）
*/

-- 解答
select
    user_id,
    email,
    -- 判定1: 先頭が英数字（a-z、A-Z、0-9）でなければならない。
    regexp_like(email, '^[a-zA-Z0-9].*') as is_begin_with_alphanumeric,
    -- 判定2: ドット（.）やハイフン（-）は先頭や末尾に配置してはならない。
    regexp_like(email, '^[^\\.\\-].*') as is_not_dot_or_hyphen_at_head,
    regexp_like(email, '.*[^\\.\\-]$') as is_not_dot_or_hyphen_at_tail,
    -- 判定3: ドメインは、ドットで区切られた 2 つの部分（ドメイン名と有効なトップレベルドメイン（TLD））で構成されている。
    regexp_like(email, '.*@[a-zA-Z0-9\\-]+\\.[a-zA-Z0-9\\-]+$') as is_domain_two_parts,
    -- 判定4: TLD は 2 文字から 6 文字でなければなりません。
    regexp_like(email, '.*\\.[a-zA-Z]{2,6}$') as is_tld_two_to_six_letters,
    /* 最終判定: すべての条件が満たされた場合にのみ有効なメールアドレスと判定 */
    (is_begin_with_alphanumeric and 
     is_not_dot_or_hyphen_at_head and
     is_not_dot_or_hyphen_at_tail and
     is_domain_two_parts and
     is_tld_two_to_six_letters
    ) as is_valid_email
from users
;


-- 別解
-- RLIKE（REGEXP）を利用するパターン
select
    user_id,
    email,
    -- 判定1: 先頭が英数字（a-z、A-Z、0-9）でなければならない。
    email rlike '^[a-zA-Z0-9].*' as is_begin_with_alphanumeric,
    -- 判定2: ドット（.）やハイフン（-）は先頭や末尾に配置してはならない。
    email regexp '^[^\\.\\-].*' as is_not_dot_or_hyphen_at_head,
    email rlike '.*[^\\.\\-]$' as is_not_dot_or_hyphen_at_tail,
    -- 判定3: ドメインは、ドットで区切られた 2 つの部分（ドメイン名と有効なトップレベルドメイン（TLD））で構成されている。
    email regexp '.*@[a-zA-Z0-9\\-]+\\.[a-zA-Z0-9\\-]+$' as is_domain_two_parts,
    -- 判定4: TLD は 2 文字から 6 文字でなければなりません。
    email rlike '.*\\.[a-zA-Z]{2,6}$' as is_tld_two_to_six_letters,
    /* 最終判定: すべての条件が満たされた場合にのみ有効なメールアドレスと判定 */
    (is_begin_with_alphanumeric and 
     is_not_dot_or_hyphen_at_head and
     is_not_dot_or_hyphen_at_tail and
     is_domain_two_parts and
     is_tld_two_to_six_letters
    ) as is_valid_email
from users
;



/*
Challenge 2: Extract Valid Dates in Multiple Formats

Objective: Use REGEXP_SUBSTR to extract dates in different formats from a string column, assuming the dates follow one of these formats:

- DD/MM/YYYY
- MM-DD-YYYY
- YYYY.MM.DD

課題 2: 複数の形式で表記された有効な日付を抽出する

目的: REGEXP_SUBSTR を使用して、文字列列からさまざまな形式の日付を抽出します。日付は、以下のいずれかの形式に従っていると仮定します。

- DD/MM/YYYY
- MM-DD-YYYY
- YYYY.MM.DD
*/

-- Start-up Code
CREATE TABLE documents (
    doc_id INT AUTOINCREMENT PRIMARY KEY,
    text_column VARCHAR(500)
);

INSERT INTO documents (text_column) 
VALUES
    ('This document was created on 15/03/2023.'),
    ('The report is due by 04-15-2022.'),
    ('Version 1.0 released on 2021.08.30.'),
    ('No date provided in this text.'),
    ('Invalid date 32/13/2020.');


/*
##########
# 解説
##########

日付の文字列としての抽出を REGEXP_SUBSTR で実施する。
ただし、31が無い月などの判定まではしない。閏年の判定ももちろんしない。
それがやりたければtry_to_dateで変換するのがいいだろう。

Perlバックスラッシュシーケンスを利用してみる。ドキュメントによると以下をサポートしている

パターンは、次のPerlバックスラッシュシーケンスもサポートしています。

- \d：10進数（0～9）。
- \D：10進数ではありません。
- \s：空白文字。
- \S：空白文字ではありません。
- \w：「単語」文字（a～z、A～Z、アンダースコア（「_」）、または10進数）。
- \W：単語の文字ではありません。
- \b：単語の境界。
- \B：単語の境界ではありません。

例によって一重引用符で囲まれた文字列定数 では、バックスラッシュシーケンスのバックスラッシュをエスケープする必要があります。
たとえば、 \d を指定するには、 \\d を使用します。
*/

-- ❌ 一見良さげだがダメな例
select
    doc_id,
    text_column,
    -- DD/MM/YYYY
    regexp_substr(text_column, '\\d{2}/\\d{2}/\\d{4}') as date_dmy,
    -- MM-DD-YYYY
    regexp_substr(text_column, $$\d{2}-\d{2}-\d{4}$$) as date_mdy,
    -- YYYY.MM.DD
    regexp_substr(text_column, '\\d{4}\\.\\d{2}\\.\\d{2}') as date_ymd
from documents
;
-- doc_id 5 のパターンを拾ってしまう。

-- ✅ 正答
select
    doc_id,
    text_column,
    -- DD/MM/YYYY
    regexp_substr(text_column, '\\d{2}/\\d{2}/\\d{4}') as date_dmy,
    try_to_date(date_dmy, 'DD/MM/YYYY') as date_dmy_casted, 
    -- MM-DD-YYYY
    regexp_substr(text_column, $$\d{2}-\d{2}-\d{4}$$) as date_mdy,
    try_to_date(date_mdy, 'MM-DD-YYYY') as date_mdy_casted,
    -- YYYY.MM.DD
    regexp_substr(text_column, '\\d{4}\\.\\d{2}\\.\\d{2}') as date_ymd,
    try_to_date(date_ymd, 'YYYY.MM.DD') as date_ymd_casted,
from documents
;



/*
Challenge 3: Mask Credit Card Numbers

Objective: Use REGEXP_REPLACE to mask all but the last 4 digits of credit card numbers in a string. The credit card numbers can be in the format XXXX-XXXX-XXXX-XXXX or XXXXXXXXXXXX.

課題 3：クレジットカード番号のマスキング

目的：REGEXP_REPLACE を使用して、文字列内のクレジットカード番号のうち、最後の 4 桁以外の部分をマスキングします。クレジットカード番号は、XXXX-XXXX-XXXX-XXXX または XXXXXXXXXXXX の形式である場合があります。
*/

-- Start-up Code
CREATE TABLE transactions (
    transaction_id INT AUTOINCREMENT PRIMARY KEY,
    card_number VARCHAR(50)
);

INSERT INTO transactions (card_number) 
VALUES
    ('1234-5678-9012-3456'),
    ('9876 5432 1098 7654'),
    ('1111222233334444'),
    ('4444-3333-2222-1111'),
    ('Invalid number 12345678901234567');


/*
##########
# 解説
##########

REGEXP_REPLACE 関数でマスキングするというお仕事

XXXX-XXXX-XXXX-XXXX または XXXXXXXXXXXX の形式であるかどうかの判定をした上で
REGEXP_REPLACE 関数でマスキングをすると良さそう
*/

select
    transaction_id,
    card_number,
    -- XXXX-XXXX-XXXX-XXXX 形式
    regexp_like(card_number, '^\\d{4}-\\d{4}-\\d{4}-\\d{4}$') as is_dashed,
    -- XXXXXXXXXXXX 形式
    regexp_like(card_number, '^\\d{16}$') as is_solid,
    -- マスキング
    CASE
        WHEN is_dashed THEN regexp_replace(card_number, '^\\d{4}-\\d{4}-\\d{4}-', '****-****-****-')
        WHEN is_solid THEN regexp_replace(card_number, '^\\d{12}', '************')
    END as masked
from transactions
;



/*
Challenge 4: Extract Hashtags from a Text Block

Objective: Use RegEx to extract all hashtags from a string, where hashtags:

- Begin with #
- Are followed by alphanumeric characters or underscores but no spaces.

課題 4：テキストブロックからハッシュタグを抽出する

目的：正規表現（RegEx）を使用して、文字列からすべてのハッシュタグを抽出する。

ここで、ハッシュタグとは：

- 「#」で始まるもの
- その後に英数字またはアンダースコアが続くが、スペースは含まれないもの。
*/

-- Start-up Code

CREATE TABLE social_posts (
    post_id INT AUTOINCREMENT PRIMARY KEY,
    text_column VARCHAR(500)
);

INSERT INTO social_posts (text_column) 
VALUES
    ('Check out our new product! #launch #excited'),
    ('Loving the weather today! #sunnyDay #relax'),
    ('Follow us at #example_page for more updates!'),
    ('No hashtags in this sentence.');


/*
##########
# 解説
##########

REGEXP_SUBSTR_ALL（もしくはREGEXP_EXTRACT_ALL）で抽出するといいと思います。

文字列・数値と_は\dを使うといいです
*/

select
    post_id,
    text_column,
    -- #launch みたいな単一のハッシュタグを抽出
    regexp_substr_all(text_column, '#\\w+') as hashtag
from social_posts
;

-- Arrayで帰ってくるので、flattenで縦持ちにしておきましょう
with

extracted_hashtags as (
    select
        post_id,
        text_column,
        regexp_substr_all(text_column, '#\\w+') as hashtags
    from social_posts
)

select
    post_id,
    text_column,
    flat.value::string as hashtag
from extracted_hashtags,
    lateral flatten(input => extracted_hashtags.hashtags) flat
;



-- #############################
-- [おまけ] Claudeの回答
-- #############################

-- CHALLENGE 1
SELECT
    user_id,
    email,
    -- REGEXP_LIKE は全体一致なので ^ と $ は不要
    REGEXP_LIKE(
        email,
        '[A-Za-z0-9]+([.-][A-Za-z0-9]+)*@[A-Za-z0-9]+(-[A-Za-z0-9]+)*\\.[A-Za-z]{2,6}'
    ) AS is_valid_email
FROM users
ORDER BY user_id;


-- CHALLENGE 2
WITH extracted AS (
    SELECT
        doc_id,
        text_column,
        REGEXP_SUBSTR(
            text_column,
               '(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}'       -- DD/MM/YYYY
            || '|(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])-[0-9]{4}'      -- MM-DD-YYYY
            || '|[0-9]{4}\\.(0[1-9]|1[0-2])\\.(0[1-9]|[12][0-9]|3[01])'  -- YYYY.MM.DD
        ) AS date_str
    FROM documents
)
SELECT
    doc_id,
    text_column,
    date_str,
    -- おまけ: 書式ごとに DATE 型へ変換する
    COALESCE(
        TRY_TO_DATE(date_str, 'DD/MM/YYYY'),
        TRY_TO_DATE(date_str, 'MM-DD-YYYY'),
        TRY_TO_DATE(date_str, 'YYYY.MM.DD')
    ) AS parsed_date
FROM extracted
ORDER BY doc_id;


-- CHALLENGE 3
SELECT
    transaction_id,
    card_number,
    REGEXP_REPLACE(
        card_number,
        '^[0-9]{4}([- ]?)[0-9]{4}([- ]?)[0-9]{4}([- ]?)([0-9]{4})$',
        '****\\1****\\2****\\3\\4'
    ) AS masked_card_number
FROM transactions
ORDER BY transaction_id;

-- CHALLENGE 4
-- 投稿ごとに配列で返す
SELECT
    post_id,
    REGEXP_SUBSTR_ALL(text_column, '#[A-Za-z0-9_]+') AS hashtags,
    REGEXP_COUNT(text_column, '#[A-Za-z0-9_]+')     AS hashtag_count
FROM social_posts
ORDER BY post_id;

-- 1 タグ 1 行に展開する
SELECT
    p.post_id,
    t.value::STRING AS hashtag
FROM social_posts p,
     LATERAL FLATTEN(input => REGEXP_SUBSTR_ALL(p.text_column, '#[A-Za-z0-9_]+')) t
ORDER BY p.post_id, t.index;

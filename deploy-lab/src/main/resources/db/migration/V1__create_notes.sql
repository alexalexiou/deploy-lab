create table notes (
    id         bigint generated always as identity primary key,
    title      varchar(255) not null,
    body       text,
    created_at timestamptz  not null
);

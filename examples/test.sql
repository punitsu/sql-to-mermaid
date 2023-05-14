-- --extensions
CREATE EXTENSION CITEXT;

--schemas
CREATE SCHEMA leave;

--tables
CREATE TABLE leave."region"(
  value TEXT PRIMARY KEY,
  description TEXT
);

INSERT INTO leave."region" (value, description)
    VALUES ('INDIA', 'Indian region');

INSERT INTO leave."region" (value, description)
    VALUES ('USA', 'USA region');

CREATE TABLE leave."user"(
    id SERIAL PRIMARY KEY,
    slack_id TEXT NOT NULL,
    external_id TEXT,
    name TEXT NOT NULL,
    email CITEXT UNIQUE,
    region TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by TEXT,
    is_admin BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE
);

ALTER TABLE leave.user ADD CONSTRAINT fk_user_region FOREIGN KEY (region) REFERENCES leave.region (value);

CREATE TABLE leave."holiday_list"(
    id SERIAL PRIMARY KEY,
    region TEXT NOT NULL,
    name TEXT NOT NULL,
    holiday_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

ALTER TABLE leave.holiday_list ADD CONSTRAINT fk_holiday_region FOREIGN KEY (region) REFERENCES leave.region (value);

CREATE TABLE leave."credit_type"(
  value TEXT PRIMARY KEY,
  description TEXT
);

CREATE TABLE leave."status"(
  value TEXT PRIMARY KEY,
  description TEXT
);

INSERT INTO leave."credit_type" (value, description)
    VALUES ('OPENING_BALANCE', 'Balance credited on opening of an account');

INSERT INTO leave."credit_type" (value, description)
    VALUES ('COMP_OFF', 'Compensatory offs');

INSERT INTO leave."status" (value, description)
    VALUES ('APPROVED', 'Request approved');

INSERT INTO leave."status" (value, description)
    VALUES ('CANCELLED', 'Request cancelled');

CREATE TABLE leave."leave_credit"(
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    year SMALLINT,
    value NUMERIC(4,1) NOT NULL,
    credit_type TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

ALTER TABLE leave.leave_credit ADD CONSTRAINT fk_credit_userid FOREIGN KEY (user_id) REFERENCES leave.user (id);
ALTER TABLE leave.leave_credit ADD CONSTRAINT fk_credit_type FOREIGN KEY (credit_type) REFERENCES leave.credit_type (value);

CREATE TABLE leave."leave_debit"(
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    year SMALLINT,
    from TIMESTAMP NOT NULL,
    to TIMESTAMP NOT NULL,
    days NUMERIC(4,1) NOT NULL,
    reason TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

ALTER TABLE leave.leave_debit ADD CONSTRAINT fk_debit_userid FOREIGN KEY (user_id) REFERENCES leave.user (id);
ALTER TABLE leave.leave_debit ADD CONSTRAINT fk_debit_status FOREIGN KEY (status) REFERENCES leave.status (value);

CREATE OR REPLACE VIEW "leave"."vu_leave_balance" AS
 SELECT c.user_id,
    c.year,
    COALESCE(d.debit_count, 0) AS leave_count,
    (COALESCE(c.credit_total, 0) - COALESCE(d.debit_total, 0)) AS balance_count
   FROM (( SELECT leave_credit.user_id,
            leave_credit.year,
            SUM(leave_credit.value) AS credit_total
           FROM leave.leave_credit
          WHERE (leave_credit.is_deleted = false)
          GROUP BY leave_credit.user_id, leave_credit.year) c
     LEFT JOIN ( SELECT leave_debit.user_id,
            leave_debit.year,
            COUNT(leave_debit.days) AS debit_count,
            SUM(leave_debit.days) AS debit_total
           FROM leave.leave_debit
          WHERE (leave_debit.is_deleted = false)
          GROUP BY leave_debit.user_id, leave_debit.year) d ON (((c.user_id = d.user_id) AND (c.year = d.year))))
  GROUP BY c.user_id, c.year, d.debit_count, c.credit_total, d.debit_total;

CREATE TABLE leave."subscriber"(
    id SERIAL PRIMARY KEY,
    is_channel BOOLEAN DEFAULT TRUE,
    subscriber_slack_id TEXT,
    user_slack_id TEXT,
    channel_slack_id TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE leave."config"(
    id SERIAL PRIMARY KEY,
    is_sync_restricted BOOLEAN DEFAULT TRUE,
    channel_slack_id TEXT,
    domain TEXT,
    leave_count INTEGER,
    is_notify_leave_remainder BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

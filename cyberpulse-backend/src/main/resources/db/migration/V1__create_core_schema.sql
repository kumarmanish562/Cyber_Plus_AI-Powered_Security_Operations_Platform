-- ============================================================
-- CyberPulse
-- V1 - Core Database Schema
-- PostgresSQL
-- ============================================================


-- ============================================================
-- UUID SUPPORT
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ============================================================
-- USERS
-- ============================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    locked BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX uk_users_username
    ON users (LOWER(username));

CREATE UNIQUE INDEX uk_users_email
    ON users (LOWER(email));


-- ============================================================
-- ROLES
-- ============================================================

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(50) NOT NULL,
    description VARCHAR(255),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_roles_name UNIQUE (name)
);


-- ============================================================
-- PERMISSIONS
-- ============================================================

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_permissions_name UNIQUE (name)
);


-- ============================================================
-- USER ROLES
-- ============================================================

CREATE TABLE user_roles (
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, role_id),

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE
);


-- ============================================================
-- ROLE PERMISSIONS
-- ============================================================

CREATE TABLE role_permissions (
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (role_id, permission_id),

    CONSTRAINT fk_role_permissions_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permissions_permission
        FOREIGN KEY (permission_id)
        REFERENCES permissions(id)
        ON DELETE CASCADE
);


-- ============================================================
-- SECURITY EVENTS
-- ============================================================

CREATE TABLE security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    event_type VARCHAR(50) NOT NULL,
    source_ip INET,
    username VARCHAR(100),
    service VARCHAR(100),
    message TEXT,

    severity VARCHAR(20) NOT NULL,

    event_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_security_event_severity
        CHECK (severity IN (
            'LOW',
            'MEDIUM',
            'HIGH',
            'CRITICAL'
        ))
);


-- ============================================================
-- DETECTION RULES
-- ============================================================

CREATE TABLE detection_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(50) NOT NULL,
    description TEXT,

    severity VARCHAR(20) NOT NULL,
    threshold_value INTEGER,
    time_window_seconds INTEGER,

    enabled BOOLEAN NOT NULL DEFAULT TRUE,

    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_detection_rules_name UNIQUE (name),

    CONSTRAINT fk_detection_rules_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_detection_rule_severity
        CHECK (severity IN (
            'LOW',
            'MEDIUM',
            'HIGH',
            'CRITICAL'
        ))
);


-- ============================================================
-- THREAT DETECTIONS
-- ============================================================

CREATE TABLE threat_detections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    rule_id UUID NOT NULL,
    event_id UUID NOT NULL,

    threat_type VARCHAR(100) NOT NULL,
    confidence_score NUMERIC(5,2),

    details JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_threat_detection_rule
        FOREIGN KEY (rule_id)
        REFERENCES detection_rules(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_threat_detection_event
        FOREIGN KEY (event_id)
        REFERENCES security_events(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_confidence_score
        CHECK (
            confidence_score IS NULL
            OR (
                confidence_score >= 0
                AND confidence_score <= 100
            )
        )
);


-- ============================================================
-- RISK ASSESSMENTS
-- ============================================================

CREATE TABLE risk_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    detection_id UUID NOT NULL,

    risk_score INTEGER NOT NULL,
    severity VARCHAR(20) NOT NULL,

    factors JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_risk_detection
        FOREIGN KEY (detection_id)
        REFERENCES threat_detections(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_risk_score
        CHECK (
            risk_score >= 0
            AND risk_score <= 100
        ),

    CONSTRAINT chk_risk_severity
        CHECK (severity IN (
            'LOW',
            'MEDIUM',
            'HIGH',
            'CRITICAL'
        ))
);


-- ============================================================
-- INCIDENTS
-- ============================================================

CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    incident_number VARCHAR(50) NOT NULL,

    title VARCHAR(200) NOT NULL,
    description TEXT,

    incident_type VARCHAR(100) NOT NULL,

    severity VARCHAR(20) NOT NULL,
    risk_score INTEGER,

    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',

    assigned_to UUID,

    detected_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ,

    CONSTRAINT uk_incidents_number
        UNIQUE (incident_number),

    CONSTRAINT fk_incident_assigned_user
        FOREIGN KEY (assigned_to)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_incident_severity
        CHECK (severity IN (
            'LOW',
            'MEDIUM',
            'HIGH',
            'CRITICAL'
        )),

    CONSTRAINT chk_incident_status
        CHECK (status IN (
            'OPEN',
            'INVESTIGATING',
            'RESOLVED',
            'CLOSED'
        )),

    CONSTRAINT chk_incident_risk_score
        CHECK (
            risk_score IS NULL
            OR (
                risk_score >= 0
                AND risk_score <= 100
            )
        )
);


-- ============================================================
-- INCIDENT EVENTS
-- ============================================================

CREATE TABLE incident_events (
    incident_id UUID NOT NULL,
    event_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (incident_id, event_id),

    CONSTRAINT fk_incident_events_incident
        FOREIGN KEY (incident_id)
        REFERENCES incidents(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_incident_events_event
        FOREIGN KEY (event_id)
        REFERENCES security_events(id)
        ON DELETE CASCADE
);


-- ============================================================
-- INCIDENT NOTES
-- ============================================================

CREATE TABLE incident_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    incident_id UUID NOT NULL,
    user_id UUID NOT NULL,

    note TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_incident_notes_incident
        FOREIGN KEY (incident_id)
        REFERENCES incidents(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_incident_notes_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);


-- ============================================================
-- AUDIT LOGS
-- ============================================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID,

    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id UUID,

    ip_address INET,

    details JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);


-- ============================================================
-- NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,

    type VARCHAR(50) NOT NULL,

    read BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_security_events_event_time
    ON security_events (event_time DESC);

CREATE INDEX idx_security_events_event_type
    ON security_events (event_type);

CREATE INDEX idx_security_events_source_ip
    ON security_events (source_ip);

CREATE INDEX idx_security_events_severity
    ON security_events (severity);

CREATE INDEX idx_security_events_username
    ON security_events (username);

CREATE INDEX idx_security_events_service
    ON security_events (service);


CREATE INDEX idx_detection_rules_enabled
    ON detection_rules (enabled);

CREATE INDEX idx_threat_detections_event
    ON threat_detections (event_id);

CREATE INDEX idx_threat_detections_rule
    ON threat_detections (rule_id);

CREATE INDEX idx_threat_detections_created
    ON threat_detections (created_at DESC);


CREATE INDEX idx_risk_assessments_detection
    ON risk_assessments (detection_id);

CREATE INDEX idx_risk_assessments_severity
    ON risk_assessments (severity);


CREATE INDEX idx_incidents_status
    ON incidents (status);

CREATE INDEX idx_incidents_severity
    ON incidents (severity);

CREATE INDEX idx_incidents_assigned_to
    ON incidents (assigned_to);

CREATE INDEX idx_incidents_created_at
    ON incidents (created_at DESC);


CREATE INDEX idx_incident_notes_incident
    ON incident_notes (incident_id);


CREATE INDEX idx_audit_logs_user
    ON audit_logs (user_id);

CREATE INDEX idx_audit_logs_created_at
    ON audit_logs (created_at DESC);

CREATE INDEX idx_audit_logs_entity
    ON audit_logs (entity_type, entity_id);


CREATE INDEX idx_notifications_user
    ON notifications (user_id);

CREATE INDEX idx_notifications_unread
    ON notifications (user_id, read);
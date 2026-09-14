-- ============================================================
-- CyberPulse
-- V2 - Seed Roles and Permissions
-- ============================================================


INSERT INTO roles (name, description)
VALUES
    ('ADMIN', 'Full system access'),
    ('SECURITY_ANALYST', 'Monitor and investigate security incidents'),
    ('SECURITY_ENGINEER', 'Manage detection rules and security configuration'),
    ('VIEWER', 'Read-only access')
ON CONFLICT (name) DO NOTHING;


INSERT INTO permissions (name, description)
VALUES

    ('USER_READ', 'View users'),
    ('USER_CREATE', 'Create users'),
    ('USER_UPDATE', 'Update users'),
    ('USER_DELETE', 'Delete users'),

    ('EVENT_READ', 'View security events'),
    ('EVENT_CREATE', 'Create security events'),

    ('RULE_READ', 'View detection rules'),
    ('RULE_CREATE', 'Create detection rules'),
    ('RULE_UPDATE', 'Update detection rules'),
    ('RULE_DELETE', 'Delete detection rules'),

    ('INCIDENT_READ', 'View incidents'),
    ('INCIDENT_CREATE', 'Create incidents'),
    ('INCIDENT_UPDATE', 'Update incidents'),

    ('AUDIT_READ', 'View audit logs'),

    ('NOTIFICATION_READ', 'View notifications'),
    ('NOTIFICATION_UPDATE', 'Update notifications')

ON CONFLICT (name) DO NOTHING;


-- ============================================================
-- ADMIN PERMISSIONS
-- ============================================================

INSERT INTO role_permissions (role_id, permission_id)

SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'ADMIN'

ON CONFLICT DO NOTHING;


-- ============================================================
-- SECURITY ANALYST
-- ============================================================

INSERT INTO role_permissions (role_id, permission_id)

SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'EVENT_READ',
        'INCIDENT_READ',
        'INCIDENT_CREATE',
        'INCIDENT_UPDATE',
        'AUDIT_READ',
        'NOTIFICATION_READ',
        'NOTIFICATION_UPDATE'
    )
WHERE r.name = 'SECURITY_ANALYST'

ON CONFLICT DO NOTHING;


-- ============================================================
-- SECURITY ENGINEER
-- ============================================================

INSERT INTO role_permissions (role_id, permission_id)

SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'EVENT_READ',
        'EVENT_CREATE',
        'RULE_READ',
        'RULE_CREATE',
        'RULE_UPDATE',
        'RULE_DELETE',
        'INCIDENT_READ',
        'AUDIT_READ'
    )
WHERE r.name = 'SECURITY_ENGINEER'

ON CONFLICT DO NOTHING;


-- ============================================================
-- VIEWER
-- ============================================================

INSERT INTO role_permissions (role_id, permission_id)

SELECT r.id, p.id
FROM roles r
JOIN permissions p
    ON p.name IN (
        'EVENT_READ',
        'INCIDENT_READ',
        'RULE_READ',
        'NOTIFICATION_READ'
    )
WHERE r.name = 'VIEWER'

ON CONFLICT DO NOTHING;
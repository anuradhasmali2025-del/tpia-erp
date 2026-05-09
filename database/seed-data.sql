-- ============================================
-- SEED DATA - DEMO NABCONS TPIA PROJECT
-- MAHARASHTRA STATE
-- ============================================

-- Disable RLS temporarily for seed data
ALTER TABLE organizations DISABLE ROW LEVEL SECURITY;
ALTER TABLE states DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE projects DISABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_stage_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE billing_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE project_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_instances DISABLE ROW LEVEL SECURITY;
ALTER TABLE invoices DISABLE ROW LEVEL SECURITY;
ALTER TABLE receipts DISABLE ROW LEVEL SECURITY;
ALTER TABLE gst_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE tds_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE revenue_shares DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_state_access DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_project_access DISABLE ROW LEVEL SECURITY;

-- ============ ORGANIZATION ============
INSERT INTO organizations (id, name, gst_no, pan_no, address, city, state, pincode, phone, email)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'TPIA India - Project Management Consultancy',
  '27AABCT1234A1Z5',
  'AABCT1234A',
  'Connaught Place, 502-A, New Delhi',
  'New Delhi',
  'Delhi',
  '110001',
  '9876543210',
  'admin@tpia.com'
)
ON CONFLICT DO NOTHING;

-- ============ STATES ============
INSERT INTO states (id, organization_id, state_code, state_name, gst_rate, tds_rate, jurisdiction)
VALUES
  ('b47ac10b-58cc-4372-a567-0e02b2c3d480'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'MH', 'Maharashtra', 18.00, 2.00, 'Maharashtra Revenue Authority'),
  ('b47ac10b-58cc-4372-a567-0e02b2c3d481'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'GJ', 'Gujarat', 18.00, 2.00, 'Gujarat Revenue Authority'),
  ('b47ac10b-58cc-4372-a567-0e02b2c3d482'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'RJ', 'Rajasthan', 18.00, 2.00, 'Rajasthan Revenue Authority')
ON CONFLICT DO NOTHING;

-- ============ USERS ============
INSERT INTO users (id, organization_id, email, full_name, role, department, phone)
VALUES
  ('a47ac10b-58cc-4372-a567-0e02b2c3d400'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'admin@tpia.com', 'System Administrator', 'SUPER_ADMIN', 'Administration', '9876543210'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d401'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'director@tpia.com', 'Rajesh Sharma', 'DIRECTOR', 'Management', '9876543211'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d402'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'pm.maharashtra@tpia.com', 'Priya Desai', 'PROJECT_MANAGER', 'Operations', '9876543212'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d403'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'pm.gujarat@tpia.com', 'Amit Patel', 'PROJECT_MANAGER', 'Operations', '9876543213'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d404'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'finance@tpia.com', 'Neha Gupta', 'FINANCE_TEAM', 'Finance', '9876543214'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d405'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'billing@tpia.com', 'Vikram Singh', 'BILLING_TEAM', 'Finance', '9876543215'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d406'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'accounts@tpia.com', 'Meera Joshi', 'ACCOUNTS_TEAM', 'Finance', '9876543216'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d407'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'site.engineer@tpia.com', 'Suresh Kumar', 'SITE_ENGINEER', 'Operations', '9876543217'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d408'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'inspector@tpia.com', 'Deepak Verma', 'INSPECTION_ENGINEER', 'Operations', '9876543218'),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d409'::uuid, 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid, 'auditor@tpia.com', 'Kavya Reddy', 'AUDITOR', 'Audit', '9876543219')
ON CONFLICT DO NOTHING;

-- ============ USER STATE ACCESS ============
INSERT INTO user_state_access (user_id, state_id, can_view, can_edit, can_approve)
VALUES
  ('a47ac10b-58cc-4372-a567-0e02b2c3d402'::uuid, 'b47ac10b-58cc-4372-a567-0e02b2c3d480'::uuid, true, true, false),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d403'::uuid, 'b47ac10b-58cc-4372-a567-0e02b2c3d481'::uuid, true, true, false)
ON CONFLICT DO NOTHING;

-- ============ WORKFLOW TEMPLATE - TPIA 7-STAGE ============
INSERT INTO workflow_templates (id, organization_id, template_name, project_type, description)
VALUES (
  'c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'TPIA Water Supply Inspection - 7 Stage',
  'TPIA',
  'Standard 7-stage TPIA workflow for water supply inspection projects'
)
ON CONFLICT DO NOTHING;

-- Workflow stages
INSERT INTO workflow_stage_templates (workflow_template_id, stage_number, stage_name, description, approval_required, approver_role, sla_days, auto_notification)
VALUES
  ('c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid, 1, 'Work Order Received', 'Work order received from client', false, NULL, 3, true),
  ('c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid, 2, 'Site Inspection', 'On-site inspection and assessment', false, NULL, 10, true),
  ('c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid, 3, 'Report Generation', 'Generate inspection report', true, ARRAY['DIRECTOR'], 15, true),
  ('c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid, 4, 'Report Approval', 'Director approval of final report', true, ARRAY['DIRECTOR'], 5, true),
  ('c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid, 5, 'Report Submission', 'Submit report to client', false, NULL, 3, true),
  ('c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid, 6, 'Invoice Generation', 'Generate tax invoice', true, ARRAY['FINANCE_TEAM'], 5, true),
  ('c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid, 7, 'Payment Tracking', 'Track payment receipt and reconciliation', false, NULL, 60, true)
ON CONFLICT DO NOTHING;

-- ============ BILLING TEMPLATE ============
INSERT INTO billing_templates (id, organization_id, template_name, project_type, billing_method, gst_applicable, tds_applicable, retention_applicable, retention_percentage, retention_release_days, penalty_applicable, penalty_percentage_per_day, revenue_share_applicable)
VALUES (
  'd47ac10b-58cc-4372-a567-0e02b2c3d600'::uuid,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'TPIA Milestone Billing',
  'TPIA',
  'MILESTONE',
  true,
  true,
  true,
  5.00,
  90,
  true,
  0.50,
  true
)
ON CONFLICT DO NOTHING;

-- ============ INVOICE TEMPLATE ============
INSERT INTO invoice_templates (id, organization_id, template_name, format_type, project_type, template_html, placeholders)
VALUES (
  'e47ac10b-58cc-4372-a567-0e02b2c3d700'::uuid,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'Standard Tax Invoice',
  'TAX_INVOICE',
  'TPIA',
  '<html><body><h1>TAX INVOICE</h1><p>Invoice No: {{invoice_no}}</p><p>Project: {{project_name}}</p><p>Amount: {{amount}}</p><p>GST: {{gst}}</p><p>TDS: {{tds}}</p></body></html>',
  '{"invoice_no": "Invoice Number", "project_name": "Project Name", "amount": "Amount", "gst": "GST Amount", "tds": "TDS Amount"}'::jsonb
)
ON CONFLICT DO NOTHING;

-- ============ PROJECT TEMPLATE ============
INSERT INTO project_templates (id, organization_id, project_type, template_name, workflow_template_id, billing_template_id, invoice_template_id, default_gst_rate, default_tds_rate, default_retention_rate, default_penalty_rate)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d800'::uuid,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'TPIA',
  'Water Supply Inspection',
  'c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid,
  'd47ac10b-58cc-4372-a567-0e02b2c3d600'::uuid,
  'e47ac10b-58cc-4372-a567-0e02b2c3d700'::uuid,
  18.00,
  2.00,
  5.00,
  0.50
)
ON CONFLICT DO NOTHING;

-- ============ NABCONS TPIA PROJECT - MAHARASHTRA ============
INSERT INTO projects (
  id,
  organization_id,
  state_id,
  project_code,
  project_name,
  description,
  project_type,
  client_name,
  client_contact,
  client_email,
  contract_value,
  contract_start_date,
  contract_end_date,
  location,
  latitude,
  longitude,
  status,
  workflow_template_id,
  billing_template_id,
  invoice_template_id,
  project_manager_id,
  finance_owner_id,
  gst_rate,
  tds_rate,
  retention_rate,
  penalty_rate,
  partner_name,
  partner_share_percentage,
  created_by
)
VALUES (
  'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'b47ac10b-58cc-4372-a567-0e02b2c3d480'::uuid,
  'NABCONS-2024-001',
  'Water Supply System Inspection & Audit - NABCONS Project',
  'Comprehensive inspection and audit of water supply system infrastructure. Includes field assessment, testing, certification, and detailed reporting.',
  'TPIA',
  'NABCONS - Water Authority Board',
  'Dr. A. K. Singh',
  'procurement@nabcons.gov.in',
  4500000.00,
  '2024-04-15',
  '2024-12-31',
  'Mumbai, Maharashtra - Water Treatment Plant and Distribution Network',
  19.0760,
  72.8777,
  'ACTIVE',
  'c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid,
  'd47ac10b-58cc-4372-a567-0e02b2c3d600'::uuid,
  'e47ac10b-58cc-4372-a567-0e02b2c3d700'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d402'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d404'::uuid,
  18.00,
  2.00,
  5.00,
  0.50,
  'NABCONS',
  15.50,
  'a47ac10b-58cc-4372-a567-0e02b2c3d400'::uuid
)
ON CONFLICT DO NOTHING;

-- ============ PROJECT MILESTONES ============
INSERT INTO project_milestones (project_id, milestone_number, milestone_name, description, percentage_of_contract, deliverables)
VALUES
  ('a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 1, 'Site Assessment & Planning', 'Initial site assessment and project planning', 15.00, ARRAY['Site Assessment Report', 'Inspection Plan']),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 2, 'Fieldwork & Testing', 'On-site inspection and testing activities', 35.00, ARRAY['Test Reports', 'Field Data', 'Photos/Videos']),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 3, 'Analysis & Report Drafting', 'Data analysis and report generation', 30.00, ARRAY['Draft Report', 'Analysis Charts']),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 4, 'Final Certification & Submission', 'Certification and final report submission', 20.00, ARRAY['Final Report', 'Certificate', 'Executive Summary'])
ON CONFLICT DO NOTHING;

-- ============ PROJECT USER ACCESS ============
INSERT INTO user_project_access (user_id, project_id, role_in_project, can_view, can_edit, can_approve)
VALUES
  ('a47ac10b-58cc-4372-a567-0e02b2c3d402'::uuid, 'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 'Project Manager', true, true, false),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d404'::uuid, 'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 'Finance Owner', true, true, true),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d407'::uuid, 'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 'Site Engineer', true, true, false),
  ('a47ac10b-58cc-4372-a567-0e02b2c3d408'::uuid, 'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid, 'Inspection Engineer', true, true, false)
ON CONFLICT DO NOTHING;

-- ============ WORKFLOW INSTANCE ============
INSERT INTO workflow_instances (id, project_id, workflow_template_id, current_stage, current_status, total_stages, initiated_by, initiated_at, completion_percentage)
VALUES (
  'b47ac10b-58cc-4372-a567-0e02b2c3d550'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid,
  'c47ac10b-58cc-4372-a567-0e02b2c3d500'::uuid,
  3,
  'UNDER_REVIEW',
  7,
  'a47ac10b-58cc-4372-a567-0e02b2c3d402'::uuid,
  '2024-07-01 09:00:00',
  43
)
ON CONFLICT DO NOTHING;

-- ============ WORKFLOW LOGS ============
INSERT INTO workflow_logs (workflow_instance_id, stage_number, stage_name, old_status, new_status, changed_by, changed_at, comment)
VALUES
  ('b47ac10b-58cc-4372-a567-0e02b2c3d550'::uuid, 1, 'Work Order Received', 'DRAFT', 'COMPLETED', 'a47ac10b-58cc-4372-a567-0e02b2c3d402'::uuid, '2024-07-01 09:30:00', 'Work order received from NABCONS'),
  ('b47ac10b-58cc-4372-a567-0e02b2c3d550'::uuid, 2, 'Site Inspection', 'SUBMITTED', 'COMPLETED', 'a47ac10b-58cc-4372-a567-0e02b2c3d408'::uuid, '2024-07-15 17:00:00', 'Field inspection completed. All samples collected.'),
  ('b47ac10b-58cc-4372-a567-0e02b2c3d550'::uuid, 3, 'Report Generation', 'SUBMITTED', 'UNDER_REVIEW', 'a47ac10b-58cc-4372-a567-0e02b2c3d402'::uuid, '2024-08-01 10:00:00', 'Submitted draft report for director approval')
ON CONFLICT DO NOTHING;

-- ============ APPROVALS ============
INSERT INTO approvals (workflow_instance_id, stage_number, approver_id, approver_role, approval_status, created_at)
VALUES (
  'b47ac10b-58cc-4372-a567-0e02b2c3d550'::uuid,
  3,
  'a47ac10b-58cc-4372-a567-0e02b2c3d401'::uuid,
  'DIRECTOR',
  'PENDING',
  '2024-08-01 10:00:00'
)
ON CONFLICT DO NOTHING;

-- ============ INVOICES ============
INSERT INTO invoices (
  id,
  organization_id,
  project_id,
  invoice_number,
  invoice_date,
  invoice_type,
  base_amount,
  gst_amount,
  gst_rate,
  tds_deducted,
  tds_rate,
  retention_held,
  retention_rate,
  gross_amount,
  net_payable,
  invoice_status,
  approval_status,
  issued_by,
  issued_date,
  due_date
)
VALUES (
  'c47ac10b-58cc-4372-a567-0e02b2c3d650'::uuid,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid,
  'INV-2024-001',
  '2024-07-31',
  'TAX_INVOICE',
  1000000.00,
  180000.00,
  18.00,
  20000.00,
  2.00,
  50000.00,
  5.00,
  1180000.00,
  1090000.00,
  'PAID',
  'APPROVED',
  'a47ac10b-58cc-4372-a567-0e02b2c3d405'::uuid,
  '2024-07-31',
  '2024-08-30'
)
ON CONFLICT DO NOTHING;

-- ============ GST ENTRY ============
INSERT INTO gst_entries (organization_id, invoice_id, project_id, gst_amount, gst_rate, invoice_date, filing_period, gst_return_filed, return_status)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'c47ac10b-58cc-4372-a567-0e02b2c3d650'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid,
  180000.00,
  18.00,
  '2024-07-31',
  '2024-07',
  true,
  'FILED'
)
ON CONFLICT DO NOTHING;

-- ============ TDS ENTRY ============
INSERT INTO tds_entries (organization_id, invoice_id, project_id, tds_amount, tds_rate, invoice_date, filing_period, tds_return_filed, return_status)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'c47ac10b-58cc-4372-a567-0e02b2c3d650'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid,
  20000.00,
  2.00,
  '2024-07-31',
  '2024-07',
  true,
  'FILED'
)
ON CONFLICT DO NOTHING;

-- ============ RECEIPT ============
INSERT INTO receipts (
  id,
  organization_id,
  invoice_id,
  project_id,
  receipt_number,
  receipt_date,
  amount_received,
  gst_credited,
  tds_received,
  retention_released,
  bank_name,
  payment_method,
  reconciliation_status,
  reconciled_by,
  reconciled_date
)
VALUES (
  'd47ac10b-58cc-4372-a567-0e02b2c3d750'::uuid,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'c47ac10b-58cc-4372-a567-0e02b2c3d650'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid,
  'REC-2024-001',
  '2024-08-15',
  1090000.00,
  180000.00,
  20000.00,
  0.00,
  'State Bank of India',
  'TRANSFER',
  'RECONCILED',
  'a47ac10b-58cc-4372-a567-0e02b2c3d406'::uuid,
  '2024-08-16'
)
ON CONFLICT DO NOTHING;

-- ============ REVENUE SHARE - NABCONS ============
INSERT INTO revenue_shares (
  organization_id,
  project_id,
  partner_name,
  partner_type,
  share_percentage,
  invoice_id,
  invoice_date,
  base_amount,
  share_amount,
  gst_on_share,
  net_share_payable,
  settlement_status
)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
  'a47ac10b-58cc-4372-a567-0e02b2c3d450'::uuid,
  'NABCONS',
  'NABCONS',
  15.50,
  'c47ac10b-58cc-4372-a567-0e02b2c3d650'::uuid,
  '2024-07-31',
  1000000.00,
  155000.00,
  27900.00,
  182900.00,
  'PENDING'
)
ON CONFLICT DO NOTHING;

-- Re-enable RLS
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE states ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_stage_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE gst_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE tds_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE revenue_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_state_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_project_access ENABLE ROW LEVEL SECURITY;

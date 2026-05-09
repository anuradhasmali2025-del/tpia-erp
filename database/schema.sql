-- ============================================
-- TPIA ENTERPRISE ERP - DATABASE SCHEMA
-- Multi-State Project Financial Management
-- ============================================

-- Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============ ORGANIZATIONS ============
CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL UNIQUE,
  gst_no VARCHAR(15) UNIQUE,
  pan_no VARCHAR(10) UNIQUE,
  address TEXT,
  city VARCHAR(100),
  state VARCHAR(100),
  pincode VARCHAR(6),
  phone VARCHAR(20),
  email VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ STATES ============
CREATE TABLE IF NOT EXISTS states (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  state_code VARCHAR(2) NOT NULL,
  state_name VARCHAR(100) NOT NULL,
  gst_rate DECIMAL(5, 2) DEFAULT 18.00,
  tds_rate DECIMAL(5, 2) DEFAULT 2.00,
  jurisdiction VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(organization_id, state_code)
);

-- ============ USERS ============
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  full_name VARCHAR(255),
  role VARCHAR(50) NOT NULL CHECK (role IN ('SUPER_ADMIN', 'DIRECTOR', 'PROJECT_MANAGER', 'FINANCE_TEAM', 'BILLING_TEAM', 'ACCOUNTS_TEAM', 'SITE_ENGINEER', 'INSPECTION_ENGINEER', 'AUDITOR', 'VIEWER')),
  department VARCHAR(100),
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ USER STATE ACCESS ============
CREATE TABLE IF NOT EXISTS user_state_access (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  state_id UUID NOT NULL REFERENCES states(id) ON DELETE CASCADE,
  can_view BOOLEAN DEFAULT true,
  can_edit BOOLEAN DEFAULT false,
  can_approve BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, state_id)
);

-- ============ WORKFLOW TEMPLATES ============
CREATE TABLE IF NOT EXISTS workflow_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  template_name VARCHAR(255) NOT NULL,
  project_type VARCHAR(50),
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ WORKFLOW STAGE TEMPLATES ============
CREATE TABLE IF NOT EXISTS workflow_stage_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workflow_template_id UUID NOT NULL REFERENCES workflow_templates(id) ON DELETE CASCADE,
  stage_number INT NOT NULL,
  stage_name VARCHAR(255) NOT NULL,
  description TEXT,
  approval_required BOOLEAN DEFAULT false,
  approver_role TEXT[] DEFAULT ARRAY[]::TEXT[],
  sla_days INT DEFAULT 5,
  auto_notification BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(workflow_template_id, stage_number)
);

-- ============ BILLING TEMPLATES ============
CREATE TABLE IF NOT EXISTS billing_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  template_name VARCHAR(255) NOT NULL,
  project_type VARCHAR(50),
  billing_method VARCHAR(50) CHECK (billing_method IN ('MILESTONE', 'MONTHLY', 'TIME_AND_MATERIAL')),
  gst_applicable BOOLEAN DEFAULT true,
  tds_applicable BOOLEAN DEFAULT true,
  retention_applicable BOOLEAN DEFAULT true,
  retention_percentage DECIMAL(5, 2) DEFAULT 5.00,
  retention_release_days INT DEFAULT 90,
  penalty_applicable BOOLEAN DEFAULT true,
  penalty_percentage_per_day DECIMAL(5, 3) DEFAULT 0.50,
  revenue_share_applicable BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ INVOICE TEMPLATES ============
CREATE TABLE IF NOT EXISTS invoice_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  template_name VARCHAR(255) NOT NULL,
  format_type VARCHAR(50) CHECK (format_type IN ('TAX_INVOICE', 'PROFORMA', 'CREDIT_NOTE')),
  project_type VARCHAR(50),
  template_html TEXT,
  placeholders JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ PROJECT TEMPLATES ============
CREATE TABLE IF NOT EXISTS project_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  project_type VARCHAR(50) NOT NULL,
  template_name VARCHAR(255) NOT NULL,
  workflow_template_id UUID REFERENCES workflow_templates(id),
  billing_template_id UUID REFERENCES billing_templates(id),
  invoice_template_id UUID REFERENCES invoice_templates(id),
  default_gst_rate DECIMAL(5, 2) DEFAULT 18.00,
  default_tds_rate DECIMAL(5, 2) DEFAULT 2.00,
  default_retention_rate DECIMAL(5, 2) DEFAULT 5.00,
  default_penalty_rate DECIMAL(5, 3) DEFAULT 0.50,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ PROJECTS ============
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  state_id UUID NOT NULL REFERENCES states(id) ON DELETE CASCADE,
  project_code VARCHAR(50) NOT NULL UNIQUE,
  project_name VARCHAR(255) NOT NULL,
  description TEXT,
  project_type VARCHAR(50),
  client_name VARCHAR(255),
  client_contact VARCHAR(20),
  client_email VARCHAR(255),
  contract_value DECIMAL(15, 2) NOT NULL,
  contract_start_date DATE,
  contract_end_date DATE,
  location VARCHAR(255),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  status VARCHAR(50) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'ON_HOLD', 'CANCELLED')),
  workflow_template_id UUID REFERENCES workflow_templates(id),
  billing_template_id UUID REFERENCES billing_templates(id),
  invoice_template_id UUID REFERENCES invoice_templates(id),
  project_manager_id UUID REFERENCES users(id),
  finance_owner_id UUID REFERENCES users(id),
  gst_rate DECIMAL(5, 2) DEFAULT 18.00,
  tds_rate DECIMAL(5, 2) DEFAULT 2.00,
  retention_rate DECIMAL(5, 2) DEFAULT 5.00,
  penalty_rate DECIMAL(5, 3) DEFAULT 0.50,
  partner_name VARCHAR(255),
  partner_share_percentage DECIMAL(5, 2),
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ PROJECT MILESTONES ============
CREATE TABLE IF NOT EXISTS project_milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  milestone_number INT NOT NULL,
  milestone_name VARCHAR(255) NOT NULL,
  description TEXT,
  percentage_of_contract DECIMAL(5, 2),
  deliverables TEXT[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(project_id, milestone_number)
);

-- ============ USER PROJECT ACCESS ============
CREATE TABLE IF NOT EXISTS user_project_access (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  role_in_project VARCHAR(100),
  can_view BOOLEAN DEFAULT true,
  can_edit BOOLEAN DEFAULT false,
  can_approve BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, project_id)
);

-- ============ WORKFLOW INSTANCES ============
CREATE TABLE IF NOT EXISTS workflow_instances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  workflow_template_id UUID NOT NULL REFERENCES workflow_templates(id),
  current_stage INT NOT NULL,
  current_status VARCHAR(50) DEFAULT 'DRAFT' CHECK (current_status IN ('DRAFT', 'IN_PROGRESS', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'COMPLETED')),
  total_stages INT NOT NULL,
  initiated_by UUID REFERENCES users(id),
  initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completion_percentage INT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ WORKFLOW LOGS ============
CREATE TABLE IF NOT EXISTS workflow_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workflow_instance_id UUID NOT NULL REFERENCES workflow_instances(id) ON DELETE CASCADE,
  stage_number INT NOT NULL,
  stage_name VARCHAR(255) NOT NULL,
  old_status VARCHAR(50),
  new_status VARCHAR(50),
  changed_by UUID REFERENCES users(id),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  comment TEXT
);

-- ============ APPROVALS ============
CREATE TABLE IF NOT EXISTS approvals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workflow_instance_id UUID NOT NULL REFERENCES workflow_instances(id) ON DELETE CASCADE,
  stage_number INT NOT NULL,
  approver_id UUID NOT NULL REFERENCES users(id),
  approver_role VARCHAR(50),
  approval_status VARCHAR(50) DEFAULT 'PENDING' CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED', 'COMMENTED')),
  approval_date TIMESTAMP,
  comments TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ INVOICES ============
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  invoice_date DATE NOT NULL,
  invoice_type VARCHAR(50) CHECK (invoice_type IN ('TAX_INVOICE', 'PROFORMA', 'CREDIT_NOTE')),
  base_amount DECIMAL(15, 2) NOT NULL,
  gst_amount DECIMAL(15, 2) DEFAULT 0,
  gst_rate DECIMAL(5, 2) DEFAULT 18.00,
  tds_deducted DECIMAL(15, 2) DEFAULT 0,
  tds_rate DECIMAL(5, 2) DEFAULT 2.00,
  retention_held DECIMAL(15, 2) DEFAULT 0,
  retention_rate DECIMAL(5, 2) DEFAULT 5.00,
  gross_amount DECIMAL(15, 2),
  net_payable DECIMAL(15, 2),
  invoice_status VARCHAR(50) DEFAULT 'DRAFT' CHECK (invoice_status IN ('DRAFT', 'ISSUED', 'PARTIALLY_PAID', 'PAID', 'CANCELLED')),
  approval_status VARCHAR(50) DEFAULT 'PENDING' CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED')),
  issued_by UUID REFERENCES users(id),
  issued_date DATE,
  due_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ RECEIPTS ============
CREATE TABLE IF NOT EXISTS receipts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  receipt_number VARCHAR(50) NOT NULL UNIQUE,
  receipt_date DATE NOT NULL,
  amount_received DECIMAL(15, 2) NOT NULL,
  gst_credited DECIMAL(15, 2),
  tds_received DECIMAL(15, 2),
  retention_released DECIMAL(15, 2),
  bank_name VARCHAR(255),
  payment_method VARCHAR(50) CHECK (payment_method IN ('TRANSFER', 'CHEQUE', 'CASH', 'ONLINE')),
  reconciliation_status VARCHAR(50) DEFAULT 'PENDING' CHECK (reconciliation_status IN ('PENDING', 'RECONCILED', 'PARTIAL')),
  reconciled_by UUID REFERENCES users(id),
  reconciled_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ GST ENTRIES ============
CREATE TABLE IF NOT EXISTS gst_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  invoice_id UUID REFERENCES invoices(id),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  gst_amount DECIMAL(15, 2) NOT NULL,
  gst_rate DECIMAL(5, 2) NOT NULL,
  invoice_date DATE NOT NULL,
  filing_period VARCHAR(7),
  gst_return_filed BOOLEAN DEFAULT false,
  return_status VARCHAR(50) CHECK (return_status IN ('PENDING', 'FILED', 'ACCEPTED', 'REJECTED')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ TDS ENTRIES ============
CREATE TABLE IF NOT EXISTS tds_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  invoice_id UUID REFERENCES invoices(id),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  tds_amount DECIMAL(15, 2) NOT NULL,
  tds_rate DECIMAL(5, 2) NOT NULL,
  invoice_date DATE NOT NULL,
  filing_period VARCHAR(7),
  tds_return_filed BOOLEAN DEFAULT false,
  return_status VARCHAR(50) CHECK (return_status IN ('PENDING', 'FILED', 'ACCEPTED', 'REJECTED')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ REVENUE SHARES ============
CREATE TABLE IF NOT EXISTS revenue_shares (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  partner_name VARCHAR(255) NOT NULL,
  partner_type VARCHAR(50),
  share_percentage DECIMAL(5, 2) NOT NULL,
  invoice_id UUID REFERENCES invoices(id),
  invoice_date DATE,
  base_amount DECIMAL(15, 2),
  share_amount DECIMAL(15, 2),
  gst_on_share DECIMAL(15, 2),
  net_share_payable DECIMAL(15, 2),
  settlement_status VARCHAR(50) DEFAULT 'PENDING' CHECK (settlement_status IN ('PENDING', 'SETTLED', 'PARTIAL')),
  settled_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ AUDIT LOGS ============
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100),
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(45)
);

-- ============ DOCUMENTS ============
CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  workflow_instance_id UUID REFERENCES workflow_instances(id),
  document_name VARCHAR(255) NOT NULL,
  document_type VARCHAR(50),
  file_path VARCHAR(500),
  file_size INT,
  uploaded_by UUID REFERENCES users(id),
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  version INT DEFAULT 1,
  is_active BOOLEAN DEFAULT true
);

-- ============ INDEXES ============
CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_states_org_id ON states(organization_id);
CREATE INDEX idx_users_org_id ON users(organization_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_projects_org_id ON projects(organization_id);
CREATE INDEX idx_projects_state_id ON projects(state_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_invoices_project_id ON invoices(project_id);
CREATE INDEX idx_invoices_status ON invoices(invoice_status);
CREATE INDEX idx_receipts_invoice_id ON receipts(invoice_id);
CREATE INDEX idx_workflow_instances_project_id ON workflow_instances(project_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_documents_project_id ON documents(project_id);

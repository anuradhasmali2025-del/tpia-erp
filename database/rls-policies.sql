-- ============================================
-- ROW-LEVEL SECURITY POLICIES
-- Multi-State Project Access Control
-- ============================================

-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE states ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_state_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_project_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE gst_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE tds_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE revenue_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- ============ ORGANIZATIONS ============
CREATE POLICY "Organizations: Super Admin Full Access"
  ON organizations FOR ALL
  USING (auth.uid() IN (
    SELECT id FROM users WHERE role = 'SUPER_ADMIN'
  ))
  WITH CHECK (auth.uid() IN (
    SELECT id FROM users WHERE role = 'SUPER_ADMIN'
  ));

-- ============ STATES ============
CREATE POLICY "States: Organization Access"
  ON states FOR ALL
  USING (organization_id IN (
    SELECT organization_id FROM users WHERE id = auth.uid()
  ))
  WITH CHECK (organization_id IN (
    SELECT organization_id FROM users WHERE id = auth.uid()
  ));

-- ============ USERS ============
CREATE POLICY "Users: View Own and Organization Users"
  ON users FOR SELECT
  USING (organization_id IN (
    SELECT organization_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "Users: Update Own Profile"
  ON users FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- ============ USER STATE ACCESS ============
CREATE POLICY "User State Access: Directors See All States"
  ON user_state_access FOR SELECT
  USING (
    user_id IN (
      SELECT id FROM users WHERE id = auth.uid()
    )
    OR auth.uid() IN (
      SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'DIRECTOR')
    )
  );

-- ============ PROJECTS ============
CREATE POLICY "Projects: Directors See All"
  ON projects FOR SELECT
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND (auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'DIRECTOR', 'FINANCE_TEAM'))
         OR id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid())
         OR state_id IN (SELECT state_id FROM user_state_access WHERE user_id = auth.uid() AND can_view = true))
  );

CREATE POLICY "Projects: PMs See Assigned Projects"
  ON projects FOR SELECT
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND (
      project_manager_id = auth.uid()
      OR id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid())
      OR state_id IN (SELECT state_id FROM user_state_access WHERE user_id = auth.uid() AND can_view = true)
    )
  );

CREATE POLICY "Projects: Edit with Permission"
  ON projects FOR UPDATE
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND (auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'DIRECTOR'))
         OR id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid() AND can_edit = true))
  )
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND (auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'DIRECTOR'))
         OR id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid() AND can_edit = true))
  );

-- ============ INVOICES ============
CREATE POLICY "Invoices: Finance Can See All"
  ON invoices FOR SELECT
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND (auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'DIRECTOR', 'FINANCE_TEAM', 'BILLING_TEAM', 'ACCOUNTS_TEAM'))
         OR project_id IN (SELECT id FROM projects WHERE project_manager_id = auth.uid())
         OR project_id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid()))
  );

CREATE POLICY "Invoices: Finance Can Modify"
  ON invoices FOR UPDATE
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM'))
  )
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM'))
  );

CREATE POLICY "Invoices: Finance Can Create"
  ON invoices FOR INSERT
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM'))
  );

-- ============ RECEIPTS ============
CREATE POLICY "Receipts: Accounts Can View and Reconcile"
  ON receipts FOR SELECT
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM', 'ACCOUNTS_TEAM'))
  );

CREATE POLICY "Receipts: Accounts Can Update"
  ON receipts FOR UPDATE
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'ACCOUNTS_TEAM'))
  )
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'ACCOUNTS_TEAM'))
  );

-- ============ GST & TDS ENTRIES ============
CREATE POLICY "GST Entries: Finance Team Access"
  ON gst_entries FOR ALL
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM', 'ACCOUNTS_TEAM'))
  )
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM'))
  );

CREATE POLICY "TDS Entries: Finance Team Access"
  ON tds_entries FOR ALL
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM', 'ACCOUNTS_TEAM'))
  )
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM'))
  );

-- ============ REVENUE SHARES ============
CREATE POLICY "Revenue Shares: Finance Team Access"
  ON revenue_shares FOR ALL
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM', 'DIRECTOR'))
  )
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'FINANCE_TEAM'))
  );

-- ============ AUDIT LOGS ============
CREATE POLICY "Audit Logs: Auditor and Super Admin Only"
  ON audit_logs FOR SELECT
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'AUDITOR'))
  );

-- ============ WORKFLOW INSTANCES ============
CREATE POLICY "Workflow Instances: Project Team Access"
  ON workflow_instances FOR SELECT
  USING (
    project_id IN (
      SELECT id FROM projects WHERE
      organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
      AND (auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'DIRECTOR', 'FINANCE_TEAM'))
           OR project_manager_id = auth.uid()
           OR id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid()))
    )
  );

-- ============ DOCUMENTS ============
CREATE POLICY "Documents: Project Team Can View"
  ON documents FOR SELECT
  USING (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND project_id IN (
      SELECT id FROM projects WHERE
      organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
      AND (auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'DIRECTOR', 'FINANCE_TEAM'))
           OR project_manager_id = auth.uid()
           OR id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid()))
    )
  );

CREATE POLICY "Documents: Project Team Can Upload"
  ON documents FOR INSERT
  WITH CHECK (
    organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
    AND project_id IN (
      SELECT id FROM projects WHERE
      organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid())
      AND (auth.uid() IN (SELECT id FROM users WHERE role IN ('SUPER_ADMIN', 'SITE_ENGINEER', 'INSPECTION_ENGINEER'))
           OR id IN (SELECT project_id FROM user_project_access WHERE user_id = auth.uid() AND can_edit = true))
    )
  );

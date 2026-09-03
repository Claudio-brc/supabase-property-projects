import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';

dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_PUBLISHABLE_KEY
);

const { data: loginData, error: loginError } =
  await supabase.auth.signInWithPassword({
    email: process.env.TEST_USER_EMAIL,
    password: process.env.TEST_USER_PASSWORD,
  });

if (loginError) {
  console.error('Login error:', loginError.message);
  process.exit(1);
}

console.log('Logged in as:', loginData.user.email);  

const { data, error } = await supabase.rpc('create_workspace', {
  p_workspace_name: 'Departamentos Bariloche',
  p_description: 'Main property workspace',
});

if (error) {
  console.error('Workspace error:', error.message);
  process.exit(1);
}

console.log('Workspace created:', data);


const { data: workspaces, error: workspacesError } = await supabase
  .from('workspaces')
  .select('*');

console.log('Workspaces:', workspaces);
console.log('Workspaces error:', workspacesError);

const { data: members, error: membersError } = await supabase
  .from('workspace_members')
  .select('*');

console.log('Members:', members);
console.log('Members error:', membersError);

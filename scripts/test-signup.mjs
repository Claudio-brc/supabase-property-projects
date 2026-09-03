import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';

dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_PUBLISHABLE_KEY
);

const { data, error } = await supabase.auth.signUp({
  email:    process.env.TEST_USER_EMAIL,
  password: process.env.TEST_USER_PASSWORD,
  options: {
    data: {
      user_code: process.env.TEST_USER_CODE,
      full_name: process.env.TEST_USER_FULL_NAME,
    },
  },
});

if (error) {
  console.error('Signup error:', error.message);
  process.exit(1);
}

const { data: profile, error: profileError } = await supabase
  .from('users')
  .select('*');

console.log('Profile:', profile);
console.log('Profile error:', profileError);

console.log('User created:', data.user);

CREATE TABLE public.users (
    user_id     UUID PRIMARY KEY
        REFERENCES auth.users(id) ON DELETE CASCADE,

    user_code   VARCHAR(30) NOT NULL,
    full_name   VARCHAR(100) NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at  TIMESTAMPTZ,

    CONSTRAINT uq_users_user_code
        UNIQUE (user_code),

    CONSTRAINT chk_users_user_code_format
        CHECK (user_code ~ '^[A-Z0-9]+(-[A-Z0-9]+)*$')
);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (
        user_id,
        user_code,
        full_name
    )
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'user_code',
        NEW.raw_user_meta_data ->> 'full_name'
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

ALTER TABLE public.users
    ENABLE ROW LEVEL SECURITY;  
      
CREATE TABLE public.workspaces (
    workspace_id   BIGSERIAL PRIMARY KEY,
    workspace_name VARCHAR(150) NOT NULL,
    description    TEXT,
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMPTZ
);

CREATE TABLE public.workspace_members (
    workspace_id BIGINT NOT NULL
        REFERENCES public.workspaces(workspace_id)
        ON DELETE CASCADE,

    user_id UUID NOT NULL
        REFERENCES public.users(user_id)
        ON DELETE CASCADE,

    role VARCHAR(20) NOT NULL
        CHECK (role IN ('OWNER', 'COLLABORATOR')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (workspace_id, user_id)
);


CREATE OR REPLACE FUNCTION public.create_workspace(
    p_workspace_name VARCHAR,
    p_description TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_workspace_id BIGINT;
BEGIN
    INSERT INTO public.workspaces (
        workspace_name,
        description
    )
    VALUES (
        p_workspace_name,
        p_description
    )
    RETURNING workspace_id
    INTO v_workspace_id;

    INSERT INTO public.workspace_members (
        workspace_id,
        user_id,
        role
    )
    VALUES (
        v_workspace_id,
        auth.uid(),
        'OWNER'
    );

    RETURN v_workspace_id;
END;
$$;

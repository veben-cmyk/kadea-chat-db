-- ============================================================
-- PROJET : Kadea_Chat - Structure & Données
-- ============================================================

-- ------------------------------------------------------------
-- 0. NETTOYAGE DES ANCIENNES TABLES
-- ------------------------------------------------------------
DROP TABLE IF EXISTS message_status CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversation_participants CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ------------------------------------------------------------
-- 1. CRÉATION DES TABLES & COMMENTAIRES
-- ------------------------------------------------------------

-- Table des utilisateurs
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    fullname VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500) DEFAULT NULL,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users             IS 'Table des utilisateurs de l''application Kadea_Chat';
COMMENT ON COLUMN users.fullname   IS 'Nom complet de l''utilisateur';
COMMENT ON COLUMN users.email      IS 'Adresse e-mail de l''utilisateur';
COMMENT ON COLUMN users.password   IS 'Mot de passe de l''utilisateur';
COMMENT ON COLUMN users.avatar_url IS 'URL de l''avatar de l''utilisateur';
COMMENT ON COLUMN users.is_online  IS 'Indique si l''utilisateur est en ligne';
COMMENT ON COLUMN users.created_at IS 'Date et heure de création de l''utilisateur';
COMMENT ON COLUMN users.updated_at IS 'Date et heure de mise à jour de l''utilisateur';


-- Table des conversations
CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) DEFAULT NULL,
    is_group BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE conversations             IS 'Table des conversations de l''application Kadea_Chat';
COMMENT ON COLUMN conversations.title      IS 'Titre de la conversation (pour les groupes)';
COMMENT ON COLUMN conversations.is_group   IS 'Indique si la conversation est un groupe ou une discussion privée';
COMMENT ON COLUMN conversations.created_at IS 'Date et heure de création de la conversation';
COMMENT ON COLUMN conversations.updated_at IS 'Date et heure de mise à jour de la conversation';


-- Table des participants aux conversations
CREATE TABLE conversation_participants (
    conversation_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (conversation_id, user_id),
    CONSTRAINT fk_participant_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    CONSTRAINT fk_participant_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

COMMENT ON TABLE conversation_participants IS 'Association N:N entre utilisateurs et conversations.';


-- Table des messages
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_message_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE RESTRICT
);

COMMENT ON TABLE messages                  IS 'Table des messages échangés dans les conversations.';
COMMENT ON COLUMN messages.conversation_id IS 'Référence à la conversation à laquelle le message appartient';
COMMENT ON COLUMN messages.sender_id       IS 'Référence à l''utilisateur qui a envoyé le message';
COMMENT ON COLUMN messages.content         IS 'Contenu du message';
COMMENT ON COLUMN messages.created_at      IS 'Date et heure d''envoi du message';
COMMENT ON COLUMN messages.updated_at      IS 'Date et heure de mise à jour du message';


-- Table du statut des messages
CREATE TABLE message_status (
    message_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('sent', 'delivered', 'read')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (message_id, user_id),
    CONSTRAINT fk_status_message FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    CONSTRAINT fk_status_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

COMMENT ON TABLE message_status             IS 'Table pour suivre le statut de chaque message pour chaque utilisateur.';
COMMENT ON COLUMN message_status.message_id IS 'Référence au message pour lequel on suit le statut';
COMMENT ON COLUMN message_status.user_id    IS 'Référence à l''utilisateur pour lequel on suit le statut';
COMMENT ON COLUMN message_status.status     IS 'Statut du message pour l''utilisateur (sent, delivered, read)';
COMMENT ON COLUMN message_status.updated_at IS 'Date et heure de mise à jour du statut';
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

-- =====================================================================
--  3. DONNÉES D'EXEMPLE
-- =====================================================================

-- ---------- Utilisateurs ----------
INSERT INTO users (fullname, email, password, is_online) VALUES
    ('Christian Mputu',  'christian.mputu@kadea.school', 'hash_christian_1', TRUE),
    ('Junior Kabongo',   'junior.kabongo@kadea.school',  'hash_junior_2', TRUE),
    ('Sarah Lukusa',     'sarah.lukusa@kadea.school',    'hash_sarah_3', FALSE),
    ('Patrick Mbala',    'patrick.mbala@kadea.school',   'hash_patrick_4', TRUE),
    ('Grâce Tshala',     'grace.tshala@kadea.school',    'hash_grace_5', FALSE),
    ('David Ilunga',     'david.ilunga@kadea.school',    'hash_david_6', TRUE);

-- ---------- Conversations ----------
-- 2 conversations privées + 2 conversations de groupe
INSERT INTO conversations (is_group, title) VALUES
    (FALSE, NULL),                       -- id 1 : Christian ↔ Junior
    (FALSE, NULL),                       -- id 2 : Sarah ↔ Patrick
    (TRUE,   'Équipe Web Dev Kadea'),      -- id 3 : Christian, Junior, Sarah, Patrick
    (TRUE,   'Cours de Base de Données');  -- id 4 : Grâce, David, Christian


-- ---------- Participants ----------
-- Conversation 1 (privée) : Christian + Junior
INSERT INTO conversation_participants (conversation_id, user_id) VALUES
    (1, 1), (1, 2);

-- Conversation 2 (privée) : Sarah + Patrick
INSERT INTO conversation_participants (conversation_id, user_id) VALUES
    (2, 3), (2, 4);

-- Conversation 3 (groupe) : Christian, Junior, Sarah, Patrick
INSERT INTO conversation_participants (conversation_id, user_id) VALUES
    (3, 1), (3, 2), (3, 3), (3, 4);

-- Conversation 4 (groupe) : Grâce, David, Christian
INSERT INTO conversation_participants (conversation_id, user_id) VALUES
    (4, 5), (4, 6), (4, 1);

-- ---------- Messages ----------
-- Conversation 1 : Christian ↔ Junior
INSERT INTO messages (content, conversation_id, sender_id) VALUES
    ('Salut Junior, tu avances sur le projet Kadea Chat ?', 1, 1),
    ('Salut Christian ! Oui, je viens de finir la page de profil.', 1, 2),
    ('Super, on se voit en cours alors ?', 1, 1);

-- Conversation 2 : Sarah ↔ Patrick
INSERT INTO messages (content, conversation_id, sender_id) VALUES
    ('Patrick, tu as reçu le cours sur la 3e forme normale ?', 2, 3),
    ('Oui Sarah, je l ai lu hier soir. Intéressant !', 2, 4);

-- Conversation 3 (groupe) : Équipe Web Dev
INSERT INTO messages (content, conversation_id, sender_id) VALUES
    ('Bonjour l équipe, réunion à 15h pour le point frontend.', 3, 1),
    ('Noté, je serai à l heure.', 3, 2),
    ('Je prépare le rapport de tests avant la réunion.', 3, 4),
    ('Parfait, merci Patrick. Sarah tu es prête ?', 3, 1),
    ('Oui, j ai fini ma partie hier.', 3, 3);

-- Conversation 4 (groupe) : Cours de Base de Données
INSERT INTO messages (content, conversation_id, sender_id) VALUES
    ('Quelqu’un peut m expliquer les clés étrangères ?', 4, 5),
    ('Bien sûr Grâce, je t envoie un exemple ce soir.', 4, 6),
    ('Merci David d avoir partagé la doc PostgreSQL.', 4, 5);

-- ---------- Statuts des messages (par destinataire) ----------
-- Message 1 (conv 1, expéditeur 1) -> destinataire 2 : lu
INSERT INTO message_status (message_id, user_id, status) VALUES
    (1, 2, 'read');
-- Message 2 (exp. 2) -> destinataire 1 : délivré
INSERT INTO message_status (message_id, user_id, status) VALUES
    (2, 1, 'delivered');
-- Message 3 (exp. 1) -> destinataire 2 : envoyé
INSERT INTO message_status (message_id, user_id, status) VALUES
    (3, 2, 'sent');

-- Conversation 2
-- Message 4 (exp. 3) -> destinataire 4 : lu
INSERT INTO message_status (message_id, user_id, status) VALUES
    (4, 4, 'read');
-- Message 5 (exp. 4) -> destinataire 3 : délivré
INSERT INTO message_status (message_id, user_id, status) VALUES
    (5, 3, 'delivered');

-- Conversation 3 (groupe) : plusieurs destinataires par message
-- Message 6 (exp. 1) -> destinataires 2, 3, 4
INSERT INTO message_status (message_id, user_id, status) VALUES
    (6, 2, 'read'),
    (6, 3, 'read'),
    (6, 4, 'delivered');
-- Message 7 (exp. 2) -> destinataires 1, 3, 4
INSERT INTO message_status (message_id, user_id, status) VALUES
    (7, 1, 'read'),
    (7, 3, 'delivered'),
    (7, 4, 'sent');
-- Message 8 (exp. 4) -> destinataires 1, 2, 3
INSERT INTO message_status (message_id, user_id, status) VALUES
    (8, 1, 'read'),
    (8, 2, 'read'),
    (8, 3, 'delivered');
-- Message 9 (exp. 1) -> destinataires 2, 3, 4
INSERT INTO message_status (message_id, user_id, status) VALUES
    (9, 2, 'sent'),
    (9, 3, 'sent'),
    (9, 4, 'sent');
-- Message 10 (exp. 3) -> destinataires 1, 2, 4
INSERT INTO message_status (message_id, user_id, status) VALUES
    (10, 1, 'delivered'),
    (10, 2, 'delivered'),
    (10, 4, 'sent');


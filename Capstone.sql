-- ==========================================
-- Streaming Platform Database Schema
-- PostgreSQL
-- ==========================================


CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'viewer' CHECK (role IN ('viewer', 'admin')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- TEAMS
-- =========================
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    city TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- GAMES
-- =========================
CREATE TABLE games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    away_team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    game_date TIMESTAMP NOT NULL,
    location TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- STREAMS
-- =========================
CREATE TABLE streams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    dacast_stream_id TEXT UNIQUE NOT NULL,
    playback_url TEXT NOT NULL,
    is_live BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- SUBSCRIPTIONS
-- =========================
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'canceled', 'expired')),
    start_date TIMESTAMP DEFAULT NOW(),
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- PAYMENTS
-- =========================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    amount NUMERIC(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    payment_provider TEXT,
    payment_status TEXT CHECK (payment_status IN ('pending', 'completed', 'failed')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- INDEXES (Performance)
-- =========================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_streams_game_id ON streams(game_id);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);

-- ==========================================
-- END OF SCHEMA
-- ==========================================
-- 🗄️ Script de Configuração Limpo - Leitura Coletiva
-- Execute este script no SQL Editor do Supabase

-- 🧹 Limpar políticas existentes (se existirem)
DROP POLICY IF EXISTS "Books are viewable by everyone" ON books;
DROP POLICY IF EXISTS "Users can insert books" ON books;
DROP POLICY IF EXISTS "Users can update own books" ON books;
DROP POLICY IF EXISTS "Clubs are viewable by everyone" ON reading_clubs;
DROP POLICY IF EXISTS "Users can insert clubs" ON reading_clubs;
DROP POLICY IF EXISTS "Users can update own clubs" ON reading_clubs;
DROP POLICY IF EXISTS "Users can view own books" ON user_books;
DROP POLICY IF EXISTS "Users can insert own books" ON user_books;
DROP POLICY IF EXISTS "Users can update own books" ON user_books;
DROP POLICY IF EXISTS "Users can delete own books" ON user_books;

-- 📚 Tabela de Livros
CREATE TABLE IF NOT EXISTS books (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255) NOT NULL,
  cover TEXT NOT NULL,
  rating DECIMAL(3,2) DEFAULT 0.0,
  genre VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🏛️ Tabela de Clubes de Leitura
CREATE TABLE IF NOT EXISTS reading_clubs (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  book_id BIGINT REFERENCES books(id) ON DELETE CASCADE,
  description TEXT,
  members_count INTEGER DEFAULT 0,
  current_chapter INTEGER DEFAULT 1,
  total_chapters INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 👥 Tabela de Livros dos Usuários (status: lendo, lido, lista de desejos)
CREATE TABLE IF NOT EXISTS user_books (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id BIGINT REFERENCES books(id) ON DELETE CASCADE,
  status VARCHAR(20) CHECK (status IN ('reading', 'read', 'wishlist')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, book_id)
);

-- 🔐 Políticas de Segurança (RLS)
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_books ENABLE ROW LEVEL SECURITY;

-- 📖 Política para livros (todos podem ler, apenas usuários autenticados podem criar/editar)
CREATE POLICY "Books are viewable by everyone" ON books
  FOR SELECT USING (true);

CREATE POLICY "Users can insert books" ON books
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own books" ON books
  FOR UPDATE USING (true);

-- 🏛️ Política para clubes de leitura
CREATE POLICY "Clubs are viewable by everyone" ON reading_clubs
  FOR SELECT USING (true);

CREATE POLICY "Users can insert clubs" ON reading_clubs
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own clubs" ON reading_clubs
  FOR UPDATE USING (true);

-- 👤 Política para livros dos usuários
CREATE POLICY "Users can view own books" ON user_books
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own books" ON user_books
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own books" ON user_books
  FOR UPDATE USING (true);

CREATE POLICY "Users can delete own books" ON user_books
  FOR DELETE USING (true);

-- 🎯 Inserir dados de exemplo
INSERT INTO books (title, author, cover, rating, genre, description) VALUES
  ('O Senhor dos Anéis', 'J.R.R. Tolkien', '/images/books/senhor dos aneis.jpg', 4.8, 'Fantasia', 'Uma épica jornada pela Terra-média'),
  ('1984', 'George Orwell', '/images/books/1984.jpg', 4.6, 'Distopia', 'Um romance distópico sobre vigilância e controle'),
  ('Dom Casmurro', 'Machado de Assis', '/images/books/Dom Casmurro.png', 4.7, 'Clássico', 'Um clássico da literatura brasileira'),
  ('O Pequeno Príncipe', 'Antoine de Saint-Exupéry', '/images/books/Pequeno Principe.jpg', 4.9, 'Ficção', 'Uma história poética sobre amizade e amor')
ON CONFLICT DO NOTHING;

-- 🏛️ Inserir clubes de exemplo
INSERT INTO reading_clubs (name, book_id, description, members_count, current_chapter, total_chapters) VALUES
  ('Clube de Leitura Clássicos', 3, 'Um clube dedicado à leitura e discussão de clássicos da literatura brasileira.', 24, 5, 12),
  ('Ficção Científica Brasil', 2, 'Clube para amantes de ficção científica e distopia.', 18, 3, 8)
ON CONFLICT DO NOTHING;

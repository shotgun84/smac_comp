// Backend credentials — ported from the index.html prototype.
// WARNING: these keys ship inside the client bundle (same as before).
// For production, move the OpenAI call behind your own backend proxy
// and rotate the key below since it has now lived in the repo.

const kSupabaseUrl = 'https://iyhprlkmaynrizgvksne.supabase.co';
const kSupabaseAnonKey = 'sb_publishable_la_0gE6zPSS3K8OBB-gSWg_OYOcSBoy';

// Injected at build time, never committed:
//   flutter build web --release --dart-define=OPENAI_API_KEY=<your-key>
const kOpenAiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
const kOpenAiModel = 'gpt-4o-mini';
bool get kOpenAiEnabled => kOpenAiKey.startsWith('sk-');

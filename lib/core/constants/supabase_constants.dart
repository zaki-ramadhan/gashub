/// Supabase configuration constants.
/// Values can be overridden via `--dart-define` during compile/run time.
abstract final class SupabaseConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cvxgrvduckoueivnsftr.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_m50Fb69Zx1NrA5alIWfAtQ_86pGmfKS',
  );
}

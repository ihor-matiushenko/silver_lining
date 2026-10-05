"""
🌐 Silver Lining AI - Public Web Policies & Deletion Form Renderer
Generates responsive, accessible HTML pages for Apple App Store & Google Play Console compliance:
- /privacy: Comprehensive Privacy Policy with direct third-party processor links
- /terms: Terms of Service & EULA incorporating Apple's Standard EULA and AI safety rules
- /delete-account: Google Play-compliant self-service Web Account & Data Deletion Portal with multi-language UI
"""

from typing import Dict

# Shared CSS styles across all legal and compliance web pages
SHARED_CSS = """
:root {
    --bg-primary: #0B0F17;
    --bg-card: rgba(30, 41, 59, 0.65);
    --border-color: rgba(255, 255, 255, 0.08);
    --text-primary: #F8FAFC;
    --text-secondary: #94A3B8;
    --accent-indigo: #6366F1;
    --accent-indigo-hover: #4F46E5;
    --accent-emerald: #10B981;
    --accent-amber: #F59E0B;
    --accent-rose: #F43F5E;
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    background-color: var(--bg-primary);
    color: var(--text-primary);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    line-height: 1.65;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    padding: 0 16px;
}

.container {
    max-width: 820px;
    margin: 40px auto 60px auto;
    width: 100%;
}

.nav-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 0 32px 0;
    border-bottom: 1px solid var(--border-color);
    margin-bottom: 32px;
}

.brand {
    display: flex;
    align-items: center;
    gap: 12px;
    text-decoration: none;
    color: var(--text-primary);
    font-weight: 700;
    font-size: 1.25rem;
}

.brand-icon {
    font-size: 1.5rem;
}

.nav-links {
    display: flex;
    gap: 18px;
    align-items: center;
}

.nav-link {
    color: var(--text-secondary);
    text-decoration: none;
    font-size: 0.9rem;
    font-weight: 500;
    transition: color 0.2s ease;
}

.nav-link:hover, .nav-link.active {
    color: var(--accent-indigo);
}

.lang-selector {
    display: flex;
    gap: 6px;
    background: rgba(15, 23, 42, 0.6);
    padding: 4px;
    border-radius: 8px;
    border: 1px solid var(--border-color);
}

.lang-btn {
    background: transparent;
    border: none;
    color: var(--text-secondary);
    padding: 4px 8px;
    border-radius: 6px;
    font-size: 0.78rem;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    transition: all 0.2s ease;
}

.lang-btn.active, .lang-btn:hover {
    background: var(--accent-indigo);
    color: #FFFFFF;
}

.glass-card {
    background: var(--bg-card);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid var(--border-color);
    border-radius: 20px;
    padding: 40px;
    box-shadow: 0 20px 45px rgba(0, 0, 0, 0.45);
}

h1 {
    font-size: 2.1rem;
    font-weight: 800;
    letter-spacing: -0.02em;
    margin-bottom: 8px;
    background: linear-gradient(135deg, #FFFFFF 0%, #CBD5E1 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.effective-date {
    color: var(--text-secondary);
    font-size: 0.88rem;
    margin-bottom: 28px;
}

.badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin-bottom: 16px;
}

.badge-privacy {
    background: rgba(16, 185, 129, 0.15);
    color: var(--accent-emerald);
    border: 1px solid rgba(16, 185, 129, 0.3);
}

.badge-terms {
    background: rgba(99, 102, 241, 0.15);
    color: var(--accent-indigo);
    border: 1px solid rgba(99, 102, 241, 0.3);
}

.badge-deletion {
    background: rgba(244, 63, 94, 0.15);
    color: var(--accent-rose);
    border: 1px solid rgba(244, 63, 94, 0.3);
}

.alert-box {
    background: rgba(245, 158, 11, 0.1);
    border: 1px solid rgba(245, 158, 11, 0.3);
    border-radius: 12px;
    padding: 16px 20px;
    margin: 24px 0;
    display: flex;
    gap: 14px;
    align-items: flex-start;
}

.alert-icon {
    font-size: 1.3rem;
    flex-shrink: 0;
    margin-top: 2px;
}

.alert-content {
    font-size: 0.92rem;
    color: #FDE68A;
}

h2 {
    font-size: 1.35rem;
    font-weight: 700;
    color: #FFFFFF;
    margin: 32px 0 14px 0;
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    padding-bottom: 8px;
}

p, ul {
    color: #CBD5E1;
    font-size: 0.98rem;
    margin-bottom: 16px;
}

ul {
    padding-left: 24px;
}

li {
    margin-bottom: 8px;
}

strong {
    color: #FFFFFF;
}

a {
    color: #818CF8;
    text-decoration: underline;
    text-underline-offset: 3px;
    transition: color 0.2s ease;
}

a:hover {
    color: #A5B4FC;
}

.footer {
    text-align: center;
    padding: 32px 0;
    margin-top: auto;
    color: var(--text-secondary);
    font-size: 0.85rem;
    border-top: 1px solid var(--border-color);
}

/* Form Styles */
.form-group {
    margin-bottom: 22px;
}

label {
    display: block;
    font-size: 0.9rem;
    font-weight: 600;
    margin-bottom: 8px;
    color: #F1F5F9;
}

input[type="email"], select, textarea {
    width: 100%;
    padding: 14px 16px;
    background: rgba(15, 23, 42, 0.8);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 10px;
    color: #FFFFFF;
    font-size: 1rem;
    outline: none;
    transition: all 0.2s ease;
}

input[type="email"]:focus, select:focus, textarea:focus {
    border-color: var(--accent-indigo);
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.25);
}

.submit-btn {
    width: 100%;
    padding: 16px;
    background: linear-gradient(135deg, #E11D48 0%, #BE123C 100%);
    color: #FFFFFF;
    border: none;
    border-radius: 12px;
    font-size: 1rem;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 0 10px 25px rgba(225, 29, 72, 0.35);
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.submit-btn:hover {
    background: linear-gradient(135deg, #F43F5E 0%, #E11D48 100%);
    box-shadow: 0 12px 28px rgba(225, 29, 72, 0.45);
    transform: translateY(-1px);
}

.submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
}

.result-card {
    display: none;
    padding: 20px;
    border-radius: 12px;
    margin-top: 24px;
    font-size: 0.95rem;
    animation: fadeIn 0.3s ease-out forwards;
}

.result-success {
    background: rgba(16, 185, 129, 0.15);
    border: 1px solid rgba(16, 185, 129, 0.4);
    color: #6EE7B7;
}

.result-error {
    background: rgba(244, 63, 94, 0.15);
    border: 1px solid rgba(244, 63, 94, 0.4);
    color: #FDA4AF;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(8px); }
    to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 640px) {
    .glass-card {
        padding: 24px 18px;
    }
    .nav-header {
        flex-direction: column;
        gap: 16px;
        align-items: flex-start;
    }
    .nav-links {
        width: 100%;
        justify-content: space-between;
    }
}
"""

def _render_nav(active_page: str, current_lang: str = "en") -> str:
    """Generates standard responsive navigation bar with page & language switches"""
    lang_codes = [("en", "EN"), ("uk", "UK"), ("es", "ES"), ("de", "DE"), ("fr", "FR")]
    lang_buttons = "".join(
        f'<a href="?lang={code}" class="lang-btn {"active" if code == current_lang else ""}">{label}</a>'
        for code, label in lang_codes
    )
    
    return f"""
    <nav class="nav-header">
        <a href="/" class="brand">
            <span class="brand-icon">✨</span>
            <span>Silver Lining</span>
        </a>
        <div class="nav-links">
            <a href="/privacy" class="nav-link {'active' if active_page == 'privacy' else ''}">Privacy</a>
            <a href="/terms" class="nav-link {'active' if active_page == 'terms' else ''}">Terms & EULA</a>
            <a href="/delete-account" class="nav-link {'active' if active_page == 'delete' else ''}">Delete Account</a>
            <div class="lang-selector">
                {lang_buttons}
            </div>
        </div>
    </nav>
    """

def _render_footer() -> str:
    return """
    <footer class="footer">
        <p>&copy; 2026 Silver Lining AI. All rights reserved. • Strictly gated by 3-Tier AI Safety Guardrails.</p>
        <p style="margin-top: 6px; font-size: 0.78rem; opacity: 0.7;">
            Contact Support & Data Protection Inquiries: <a href="mailto:support@silverlining.app">support@silverlining.app</a>
        </p>
    </footer>
    """

# ==========================================
# 1. 🔒 Privacy Policy Page HTML
# ==========================================
def render_privacy_page(lang: str = "en") -> str:
    """
    Renders official Privacy Policy complying with:
    - Apple App Store Guideline 5.1.1 (Data Collection & Storage)
    - Google Play Data Safety Mandates & Developer Policies
    - GDPR & CCPA Transparency Standards
    """
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - Silver Lining AI</title>
    <meta name="description" content="Official Privacy Policy for Silver Lining AI: detailing zero-retention guest mode, encrypted cloud sync, AI safety guardrails, and account deletion rights.">
    <style>{SHARED_CSS}</style>
</head>
<body>
    <div class="container">
        {_render_nav(active_page="privacy", current_lang=lang)}
        
        <main class="glass-card">
            <span class="badge badge-privacy">App Store & Google Play Compliant</span>
            <h1>Privacy Policy</h1>
            <p class="effective-date">Effective Date: October 1, 2026 • Version 1.1</p>

            <p>
                At <strong>Silver Lining AI</strong>, we believe your personal thoughts, stresses, and reflections belong to you alone. 
                This Privacy Policy describes our strict data handling practices in complete compliance with the 
                <strong>Apple App Store Review Guidelines (Guideline 5.1.1)</strong> and the <strong>Google Play Data Safety Section</strong>.
            </p>

            <h2>1. Our Dual-Tier Data Architecture</h2>
            <p>We operate under an explicit privacy-first dual-tier model:</p>
            <ul>
                <li>
                    <strong>🆓 Guest Users (Local Only, 0 Cloud Storage):</strong> 
                    When using Silver Lining in guest mode, your prompts are evaluated ephemerally by our AI model and safety engine. 
                    <strong>Zero personal reflections or thought logs are stored in our backend database.</strong> All history is stored exclusively on your physical device using local encrypted storage.
                </li>
                <li>
                    <strong>🔒 Authenticated Users (Encrypted Cloud Sync):</strong> 
                    When you voluntarily sign up via Email, Sign in with Apple, or Sign in with Google, we store your email address and synced reflections in an encrypted PostgreSQL database to allow cross-device backup.
                </li>
            </ul>

            <h2>2. Generative AI Processing & Safety Guardrails</h2>
            <p>
                Silver Lining leverages state-of-the-art Large Language Models to transform stressful thoughts into constructive psychological perspectives:
            </p>
            <ul>
                <li><strong>No Advertising Profiling:</strong> Your inputs and AI-generated reframings are <strong>never sold</strong> to advertisers, data brokers, or commercial marketing firms.</li>
                <li><strong>No Model Retraining:</strong> We do not use your private personal journal entries to train public generative AI foundational models.</li>
                <li><strong>3-Tier Safety Guardrails:</strong> Prompts are strictly checked prior to generation to intercept crisis situations (self-harm, violence, abuse). When crisis inputs are detected, emergency hotline information (such as 988) is provided immediately and no reframing occurs.</li>
            </ul>

            <h2>3. Third-Party Infrastructure & Compliance Links</h2>
            <p>
                To provide secure authentication and cloud synchronization, we partner exclusively with enterprise infrastructure providers that adhere to international security and privacy benchmarks:
            </p>
            <ul>
                <li><strong>Supabase Authentication:</strong> Handles secure identity management, OAuth 2.0 tokens, and ES256 cryptographic verification. (<a href="https://supabase.com/privacy" target="_blank" rel="noopener">Supabase Privacy Policy</a>)</li>
                <li><strong>Sign in with Apple:</strong> Supports Apple's Private Relay email hiding feature. (<a href="https://www.apple.com/legal/privacy/" target="_blank" rel="noopener">Apple Privacy Policy</a>)</li>
                <li><strong>Sign in with Google:</strong> Provides secure Google identity federation. (<a href="https://policies.google.com/privacy" target="_blank" rel="noopener">Google Privacy Policy</a>)</li>
            </ul>

            <h2>4. Data Retention & Right to be Forgotten (GDPR & CCPA)</h2>
            <p>
                You retain complete ownership over your data at all times:
            </p>
            <ul>
                <li><strong>In-App Immediate Deletion:</strong> You can purge individual history items or your entire account with a single tap in the app's Account Settings.</li>
                <li><strong>Web-Based Deletion Portal:</strong> In full compliance with Google Play Data Safety policies, if you have uninstalled the app or lost access to your device, you may request complete deletion of your account and reflections via our <a href="/delete-account">Web Account Deletion Portal</a>.</li>
                <li><strong>Permanent Cascade:</strong> When an account is deleted, your account row, synced reflections, safety logs, and report records are permanently purged from PostgreSQL.</li>
            </ul>

            <h2>5. Security & Encryption in Transit</h2>
            <p>
                All communications between the Silver Lining mobile application and our backend APIs are strictly encrypted using Transport Layer Security (TLS 1.3 / HTTPS). Authentication utilizes industry-standard JSON Web Tokens (JWT) verified via asymmetric public-key cryptography.
            </p>

            <h2>6. Governing Language</h2>
            <p style="font-size: 0.9rem; opacity: 0.85;">
                This Privacy Policy is provided in English as the official, legally binding document across all app stores worldwide. Any local translations provided are for informational convenience only.
            </p>
        </main>

        {_render_footer()}
    </div>
</body>
</html>"""

# ==========================================
# 2. 📜 Terms of Service & EULA HTML
# ==========================================
def render_terms_page(lang: str = "en") -> str:
    """
    Renders official Terms of Service & EULA complying with:
    - Apple App Store Review Guideline 1.2 (User-Generated & AI Content EULA)
    - Apple Standard EULA incorporation (apple.com/legal/internet-services/itunes/dev/stdeula/)
    - Apple Guideline 1.4.1 & Google Play Health Policy (Medical & Wellness Disclaimer)
    """
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms of Service & EULA - Silver Lining AI</title>
    <meta name="description" content="Terms of Service & End User License Agreement (EULA) for Silver Lining AI. Incorporates Apple Standard EULA and AI safety rules.">
    <style>{SHARED_CSS}</style>
</head>
<body>
    <div class="container">
        {_render_nav(active_page="terms", current_lang=lang)}
        
        <main class="glass-card">
            <span class="badge badge-terms">Apple EULA & Google Play Terms</span>
            <h1>Terms of Service & EULA</h1>
            <p class="effective-date">Effective Date: October 1, 2026 • Version 1.1</p>

            <div class="alert-box">
                <span class="alert-icon">🩺</span>
                <div class="alert-content">
                    <strong>Medical & Wellness Disclaimer:</strong> Silver Lining is an AI self-reflection and cognitive reframing tool. 
                    It is <strong>NOT</strong> a licensed healthcare provider, therapy clinic, or emergency crisis service. 
                    If you are experiencing acute distress or self-harm thoughts, please call <strong>988</strong> or contact emergency services immediately.
                </div>
            </div>

            <h2>1. Acceptance of Terms & Apple Standard EULA</h2>
            <p>
                By downloading, installing, or using the Silver Lining application, you agree to be bound by these Terms of Service. 
                For users accessing the app on iOS, your use is also subject to 
                <a href="https://www.apple.com/legal/internet-services/itunes/dev/stdeula/" target="_blank" rel="noopener">Apple's Standard Licensed Application End User License Agreement (Apple Standard EULA)</a>, 
                which is incorporated herein by reference.
            </p>

            <h2>2. Permitted Use & Zero-Tolerance Policy (Apple Guideline 1.2)</h2>
            <p>
                Silver Lining is designed to foster constructive, positive perspective reframing for everyday stress and cognitive challenges. 
                In strict accordance with <strong>Apple Guideline 1.2</strong> and <strong>Google Play GenAI Policies</strong>, we enforce a strict 
                <strong>zero-tolerance policy</strong> against abusive, harmful, or objectionable content. Users may NOT submit prompts or content that:
            </p>
            <ul>
                <li>Encourages, facilitates, or depicts suicide, self-harm, or self-mutilation.</li>
                <li>Promotes violence, illegal acts, cyberattacks, or criminal misconduct.</li>
                <li>Engages in severe harassment, hate speech, defamation, or sexual exploitation.</li>
                <li>Attempts to bypass or jailbreak our multi-tier AI safety filters.</li>
            </ul>
            <p>
                Violations of these safety standards result in immediate refusal of the request, logging to our safety audit engine, and potential suspension or termination of user accounts.
            </p>

            <h2>3. AI-Generated Perspectives & Limitations</h2>
            <p>
                Silver Lining utilizes automated artificial intelligence to provide alternative positive viewpoints:
            </p>
            <ul>
                <li><strong>Subjective Mindset Support:</strong> The generated reframings are automated linguistic suggestions intended solely for mindfulness and reflection.</li>
                <li><strong>No Professional Guarantee:</strong> Silver Lining makes no warranty that AI perspectives will be completely error-free, factually exhaustive, or suited to every personal emotional situation.</li>
                <li><strong>User Agency:</strong> You remain solely responsible for how you interpret and apply cognitive reframings in your personal life.</li>
            </ul>

            <h2>4. User Reporting & Objectionable Content Moderation</h2>
            <p>
                In compliance with App Store requirements, Silver Lining provides an in-app flag mechanism on every generated perspective. Users may submit reports for harmful, offensive, or inaccurate outputs. Our automated moderation pipeline logs and audits all reported items to continuously safeguard our community.
            </p>

            <h2>5. Account Termination & Deletion</h2>
            <p>
                You may terminate your agreement with Silver Lining at any time by deleting your account via the mobile app settings or through our public <a href="/delete-account">Web Account Deletion Portal</a>. Upon deletion, all associated cloud reflection records are permanently removed from our active database.
            </p>

            <h2>6. Governing Law</h2>
            <p style="font-size: 0.9rem; opacity: 0.85;">
                These terms are governed by applicable laws. The English language version of this agreement shall control in all respects.
            </p>
        </main>

        {_render_footer()}
    </div>
</body>
</html>"""

# ==========================================
# 3. 🗑️ Web Account Deletion Portal HTML
# ==========================================
DELETION_UI_TRANSLATIONS: Dict[str, Dict[str, str]] = {
    "en": {
        "title": "Account & Data Deletion",
        "badge": "Google Play Data Safety Mandate",
        "subtitle": "Self-service request portal to permanently delete your account and reflection history.",
        "noticeTitle": "Important Information Regarding Account Deletion:",
        "point1": "Registered Users: Entering your registered email permanently purges your account row, synced reflection history, safety logs, and report records from our PostgreSQL database.",
        "point2": "Guest Users: If you only used Silver Lining as a guest without creating an account, we store 0 data on our servers. Your data is stored strictly on your local device and is removed when you clear app data or uninstall the app.",
        "point3": "Permanent & Irreversible: Once submitted, cloud-synced reflections cannot be recovered.",
        "emailLabel": "Registered Account Email Address",
        "emailPlaceholder": "you@example.com",
        "reasonLabel": "Reason for leaving (Optional)",
        "reasonOpt1": "Select a reason (optional)",
        "reasonOpt2": "I don't use the app anymore",
        "reasonOpt3": "Privacy concerns",
        "reasonOpt4": "Switching to another device",
        "reasonOpt5": "Other reason",
        "submitBtn": "Permanently Delete My Account & Data",
        "submitting": "Processing deletion...",
    },
    "uk": {
        "title": "Видалення Акаунту та Даних",
        "badge": "Вимога Google Play Data Safety",
        "subtitle": "Портал самообслуговування для повного видалення вашого акаунту та історії думок.",
        "noticeTitle": "Важлива інформація щодо видалення даних:",
        "point1": "Зареєстровані користувачі: Введення вашої електронної пошти назавжди видаляє акаунт, синхронізовану історію, логи безпеки та звіти з бази даних PostgreSQL.",
        "point2": "Гостьові користувачі: Якщо ви користувалися додатком у гостьовому режимі без реєстрації, ми не зберігаємо жодних даних на серверах. Вони зберігаються лише на вашому пристрої.",
        "point3": "Незворотно: Після підтвердження відновлення хмарних даних неможливе.",
        "emailLabel": "Електронна пошта зареєстрованого акаунту",
        "emailPlaceholder": "you@example.com",
        "reasonLabel": "Причина видалення (необов'язково)",
        "reasonOpt1": "Оберіть причину (необов'язково)",
        "reasonOpt2": "Більше не користуюся додатком",
        "reasonOpt3": "Питання конфіденційності",
        "reasonOpt4": "Перехід на інший пристрій",
        "reasonOpt5": "Інша причина",
        "submitBtn": "Назавжди видалити мій акаунт і дані",
        "submitting": "Обробка видалення...",
    },
    "es": {
        "title": "Eliminación de Cuenta y Datos",
        "badge": "Requisito de Google Play Data Safety",
        "subtitle": "Portal de autoservicio para eliminar permanentemente su cuenta e historial.",
        "noticeTitle": "Información importante sobre la eliminación:",
        "point1": "Usuarios registrados: Al ingresar su correo, se eliminan permanentemente su cuenta, historial sincronizado y registros de nuestra base de datos PostgreSQL.",
        "point2": "Usuarios invitados: Si usó el modo invitado sin cuenta, no almacenamos ningún dato en nuestros servidores. Sus datos existen únicamente en su dispositivo.",
        "point3": "Permanente e irreversible: Los datos eliminados no se pueden recuperar.",
        "emailLabel": "Correo electrónico de la cuenta registrada",
        "emailPlaceholder": "you@example.com",
        "reasonLabel": "Motivo (Opcional)",
        "reasonOpt1": "Seleccione un motivo (opcional)",
        "reasonOpt2": "Ya no uso la aplicación",
        "reasonOpt3": "Preocupaciones de privacidad",
        "reasonOpt4": "Cambiando a otro dispositivo",
        "reasonOpt5": "Otro motivo",
        "submitBtn": "Eliminar permanentemente mi cuenta y datos",
        "submitting": "Procesando eliminación...",
    },
    "de": {
        "title": "Konto- und Datenlöschung",
        "badge": "Google Play Data Safety Richtlinie",
        "subtitle": "Self-Service-Portal zur dauerhaften Löschung Ihres Kontos und Verlaufs.",
        "noticeTitle": "Wichtige Informationen zur Kontolöschung:",
        "point1": "Registrierte Benutzer: Durch Eingabe Ihrer E-Mail-Adresse werden Ihr Konto und alle synchronisierten Daten dauerhaft aus PostgreSQL gelöscht.",
        "point2": "Gastbenutzer: Wenn Sie den Gastmodus ohne Konto verwendet haben, speichern wir keine Daten auf unseren Servern. Die Daten liegen nur auf Ihrem Gerät.",
        "point3": "Unwiderruflich: Gelöschte Daten können nicht wiederhergestellt werden.",
        "emailLabel": "Registrierte E-Mail-Adresse",
        "emailPlaceholder": "you@example.com",
        "reasonLabel": "Grund für die Löschung (Optional)",
        "reasonOpt1": "Grund auswählen (optional)",
        "reasonOpt2": "Ich nutze die App nicht mehr",
        "reasonOpt3": "Datenschutzbedenken",
        "reasonOpt4": "Wechsel auf ein anderes Gerät",
        "reasonOpt5": "Anderer Grund",
        "submitBtn": "Mein Konto & Daten endgültig löschen",
        "submitting": "Löschung wird verarbeitet...",
    },
    "fr": {
        "title": "Suppression de Compte et Données",
        "badge": "Exigence Google Play Data Safety",
        "subtitle": "Portail libre-service pour supprimer définitivement votre compte et vos réflexions.",
        "noticeTitle": "Informations importantes sur la suppression :",
        "point1": "Utilisateurs inscrits : Saisir votre e-mail supprime définitivement votre compte et votre historique synchronisé de notre base PostgreSQL.",
        "point2": "Utilisateurs invités : Si vous avez utilisé l'application en mode invité, aucune donnée n'est stockée sur nos serveurs.",
        "point3": "Irréversible : Une fois supprimées, les données ne peuvent pas être récupérées.",
        "emailLabel": "Adresse e-mail du compte inscrit",
        "emailPlaceholder": "you@example.com",
        "reasonLabel": "Raison du départ (Facultatif)",
        "reasonOpt1": "Sélectionnez une raison (facultatif)",
        "reasonOpt2": "Je n'utilise plus l'application",
        "reasonOpt3": "Préoccupations de confidentialité",
        "reasonOpt4": "Changement d'appareil",
        "reasonOpt5": "Autre raison",
        "submitBtn": "Supprimer définitivement mon compte et mes données",
        "submitting": "Traitement en cours...",
    }
}

def render_delete_account_page(lang: str = "en") -> str:
    """
    Renders interactive, localized Account Deletion portal complying with:
    - Google Play Data Safety Requirement for web deletion URL
    - Multi-language interactive UI with live async form submission
    """
    selected_lang = lang if lang in DELETION_UI_TRANSLATIONS else "en"
    t = DELETION_UI_TRANSLATIONS[selected_lang]

    return f"""<!DOCTYPE html>
<html lang="{selected_lang}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{t["title"]} - Silver Lining AI</title>
    <meta name="description" content="Self-service portal to permanently delete your Silver Lining AI account and all cloud reflection history.">
    <style>{SHARED_CSS}</style>
</head>
<body>
    <div class="container">
        {_render_nav(active_page="delete", current_lang=selected_lang)}
        
        <main class="glass-card">
            <span class="badge badge-deletion">{t["badge"]}</span>
            <h1>{t["title"]}</h1>
            <p style="color: #94A3B8; margin-bottom: 24px;">{t["subtitle"]}</p>

            <div class="alert-box">
                <span class="alert-icon">⚠️</span>
                <div class="alert-content">
                    <strong>{t["noticeTitle"]}</strong>
                    <ul style="margin: 8px 0 0 16px; padding: 0;">
                        <li>{t["point1"]}</li>
                        <li>{t["point2"]}</li>
                        <li><strong>{t["point3"]}</strong></li>
                    </ul>
                </div>
            </div>

            <form id="deletion-form">
                <div class="form-group">
                    <label for="email">{t["emailLabel"]}</label>
                    <input type="email" id="email" name="email" required placeholder="{t["emailPlaceholder"]}" autocomplete="email">
                </div>

                <div class="form-group">
                    <label for="reason">{t["reasonLabel"]}</label>
                    <select id="reason" name="reason">
                        <option value="">{t["reasonOpt1"]}</option>
                        <option value="not_using">{t["reasonOpt2"]}</option>
                        <option value="privacy">{t["reasonOpt3"]}</option>
                        <option value="device_switch">{t["reasonOpt4"]}</option>
                        <option value="other">{t["reasonOpt5"]}</option>
                    </select>
                </div>

                <button type="submit" id="submit-button" class="submit-btn">
                    <span>🗑️</span>
                    <span id="btn-text">{t["submitBtn"]}</span>
                </button>
            </form>

            <div id="result-box" class="result-card"></div>
        </main>

        {_render_footer()}
    </div>

    <script>
        const form = document.getElementById('deletion-form');
        const submitBtn = document.getElementById('submit-button');
        const btnText = document.getElementById('btn-text');
        const resultBox = document.getElementById('result-box');

        form.addEventListener('submit', async (e) => {{
            e.preventDefault();
            const email = document.getElementById('email').value.trim();
            const reason = document.getElementById('reason').value;

            if (!email) return;

            submitBtn.disabled = true;
            btnText.innerText = "{t["submitting"]}";
            resultBox.style.display = 'none';

            try {{
                const res = await fetch('/api/v1/auth/request-web-deletion', {{
                    method: 'POST',
                    headers: {{ 'Content-Type': 'application/json' }},
                    body: JSON.stringify({{ email, reason }})
                }});

                const data = await res.json();

                resultBox.style.display = 'block';
                if (res.ok) {{
                    resultBox.className = 'result-card result-success';
                    resultBox.innerHTML = '<strong>✅ Request Processed:</strong> ' + data.message;
                    form.reset();
                }} else {{
                    resultBox.className = 'result-card result-error';
                    resultBox.innerHTML = '<strong>❌ Error:</strong> ' + (data.detail || 'Could not process request.');
                }}
            }} catch (err) {{
                resultBox.style.display = 'block';
                resultBox.className = 'result-card result-error';
                resultBox.innerHTML = '<strong>❌ Connection Error:</strong> Unable to reach server. Please try again.';
            }} finally {{
                submitBtn.disabled = false;
                btnText.innerText = "{t["submitBtn"]}";
            }}
        }});
    </script>
</body>
</html>"""

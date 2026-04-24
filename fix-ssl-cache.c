/*
 * vsftpd 3.0.5 + OpenSSL 3.x: SSL_CTX session cache state gets corrupted
 * across fork() boundaries, causing SIGSEGV on the second TLS session's
 * cleanup. Intercept SSL_CTX_new and disable caching before vsftpd uses it.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <openssl/ssl.h>

SSL_CTX *SSL_CTX_new(const SSL_METHOD *method) {
    typedef SSL_CTX *(*fn_t)(const SSL_METHOD *);
    fn_t real = (fn_t)dlsym(RTLD_NEXT, "SSL_CTX_new");
    SSL_CTX *ctx = real(method);
    if (ctx)
        SSL_CTX_set_session_cache_mode(ctx, SSL_SESS_CACHE_OFF);
    return ctx;
}

import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './services/auth';

/// Protege rotas que exigem sessao (ex: /admin). Sem token, redireciona
/// pra /login em vez de deixar a tela tentar chamar a API e falhar com 401.
export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.estaLogado()) {
    return true;
  }

  return router.parseUrl('/login');
};

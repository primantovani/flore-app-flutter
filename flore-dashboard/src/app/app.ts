import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { filter } from 'rxjs';
import { AuthService } from './services/auth';

@Component({
  selector: 'app-root',
  imports: [CommonModule, RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('flore-dashboard');

  // Navbar reage ao estado real de sessao: "Entrar" deslogada, "Peças" +
  // "Sair" logada. Recalculado a cada navegacao (login/logout mudam a
  // sessao sem recriar o componente raiz).
  protected readonly logado = signal(false);

  constructor(private authService: AuthService, private router: Router) {
    this.logado.set(this.authService.estaLogado());
    this.router.events
      .pipe(filter((evento) => evento instanceof NavigationEnd))
      .subscribe(() => this.logado.set(this.authService.estaLogado()));
  }

  sair(): void {
    this.authService.logout();
    this.logado.set(false);
    this.router.navigate(['/login']);
  }
}

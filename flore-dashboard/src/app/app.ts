import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { filter } from 'rxjs';
import { AuthService } from './services/auth';
import { ToastService } from './services/toast';

@Component({
  selector: 'app-root',
  imports: [CommonModule, RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('flore-dashboard');

  // Navbar reage ao estado real de sessao: "Entrar" deslogada, "Peças" +
  // saudacao + "Sair" logada. Recalculado a cada navegacao (login/logout
  // mudam a sessao sem recriar o componente raiz).
  protected readonly logado = signal(false);
  protected readonly nomeUsuaria = signal<string | null>(null);

  constructor(private authService: AuthService, private router: Router, protected toastService: ToastService) {
    this.atualizarSessao();
    this.router.events
      .pipe(filter((evento) => evento instanceof NavigationEnd))
      .subscribe(() => this.atualizarSessao());
  }

  private atualizarSessao(): void {
    this.logado.set(this.authService.estaLogado());
    this.nomeUsuaria.set(this.authService.getUsuarioAtual()?.name ?? null);
  }

  sair(): void {
    this.authService.logout();
    this.atualizarSessao();
    this.router.navigate(['/login']);
  }
}

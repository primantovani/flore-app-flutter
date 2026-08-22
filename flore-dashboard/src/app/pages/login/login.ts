import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth';
import { LoginRequest } from '../../models/auth.model';

@Component({
  selector: 'app-login',
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.css'
})
export class Login {
  credenciais: LoginRequest = { email: '', password: '' };
  erro = '';
  carregando = false;

  constructor(private authService: AuthService, private router: Router) {}

  entrar(): void {
    this.erro = '';
    this.carregando = true;

    this.authService.login(this.credenciais).subscribe({
      next: () => {
        this.carregando = false;
        this.router.navigate(['/admin']);
      },
      error: () => {
        this.carregando = false;
        this.erro = 'E-mail ou senha inválidos, ou o servidor está indisponível.';
      }
    });
  }
}

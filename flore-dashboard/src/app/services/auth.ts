import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { API_URL } from '../api-config';
import { LoginRequest, SignupRequest, AuthResponse, UserResponse } from '../models/auth.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private baseUrl = `${API_URL}/api/auth`;
  private tokenKey = 'flore_token';
  private userKey = 'flore_user';

  constructor(private http: HttpClient) { }

  login(dados: LoginRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/login`, dados).pipe(
      tap((resposta) => this.salvarSessao(resposta))
    );
  }

  signup(dados: SignupRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/signup`, dados).pipe(
      tap((resposta) => this.salvarSessao(resposta))
    );
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.userKey);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  /// Usuaria da sessao atual (nome/e-mail), pra saudacao no navbar. Vem do
  /// login/signup, guardado junto com o token (mesmo padrao do AuthService
  /// do Flutter).
  getUsuarioAtual(): UserResponse | null {
    const raw = localStorage.getItem(this.userKey);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as UserResponse;
    } catch {
      return null;
    }
  }

  estaLogado(): boolean {
    return !!this.getToken();
  }

  private salvarSessao(resposta: AuthResponse): void {
    localStorage.setItem(this.tokenKey, resposta.token);
    localStorage.setItem(this.userKey, JSON.stringify(resposta.user));
  }
}

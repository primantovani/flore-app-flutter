import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { API_URL } from '../api-config';
import { LoginRequest, SignupRequest, AuthResponse } from '../models/auth.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private baseUrl = `${API_URL}/api/auth`;
  private tokenKey = 'flore_token';

  constructor(private http: HttpClient) { }

  login(dados: LoginRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/login`, dados).pipe(
      tap((resposta) => this.salvarToken(resposta.token))
    );
  }

  signup(dados: SignupRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/signup`, dados).pipe(
      tap((resposta) => this.salvarToken(resposta.token))
    );
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  estaLogado(): boolean {
    return !!this.getToken();
  }

  private salvarToken(token: string): void {
    localStorage.setItem(this.tokenKey, token);
  }
}

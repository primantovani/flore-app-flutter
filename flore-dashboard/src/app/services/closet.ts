import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { API_URL } from '../api-config';
import { Peca } from '../models/peca.model';

@Injectable({
  providedIn: 'root'
})
export class ClosetService {
  private baseUrl = `${API_URL}/api/closet`;

  constructor(private http: HttpClient) { }

  /// Marketplace: todas as pecas disponiveis, de todas as usuarias (publico).
  listarDisponiveis(): Observable<Peca[]> {
    return this.http.get<Peca[]>(this.baseUrl);
  }

  /// Meu closet: pecas da usuaria logada, incluindo vendidas.
  listarMinhas(): Observable<Peca[]> {
    return this.http.get<Peca[]>(`${this.baseUrl}/mine`);
  }

  criarPeca(peca: Peca): Observable<Peca> {
    return this.http.post<Peca>(this.baseUrl, peca);
  }

  atualizarPeca(id: number, peca: Peca): Observable<Peca> {
    return this.http.put<Peca>(`${this.baseUrl}/${id}`, peca);
  }

  marcarStatus(id: number, status: 'available' | 'sold'): Observable<Peca> {
    return this.http.patch<Peca>(`${this.baseUrl}/${id}/status`, null, { params: { status } });
  }

  removerPeca(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }
}

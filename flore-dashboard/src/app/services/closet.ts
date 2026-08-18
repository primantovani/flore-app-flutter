import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Peca } from '../models/peca.model';

@Injectable({
  providedIn: 'root'
})
export class ClosetService {
  private baseUrl = 'https://flore-back.onrender.com/api/closet';

  constructor(private http: HttpClient) { }

  listarPecas(): Observable<Peca[]> {
    return this.http.get<Peca[]>(this.baseUrl);
  }

  criarPeca(peca: Peca): Observable<Peca> {
    return this.http.post<Peca>(this.baseUrl, peca);
  }

  removerPeca(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }
}

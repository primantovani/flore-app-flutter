import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { ClosetService } from '../../services/closet';
import { AuthService } from '../../services/auth';
import { Peca } from '../../models/peca.model';

interface CategoriaResumo {
  nome: string;
  quantidade: number;
}

@Component({
  selector: 'app-home',
  imports: [CommonModule, RouterLink],
  templateUrl: './home.html',
  styleUrl: './home.css'
})
export class Home implements OnInit {
  carregando = true;
  erro = false;

  // Marketplace: peças disponíveis de todas as usuárias (dado público).
  disponiveis: Peca[] = [];

  // Meu closet: só carregado se estiver logada (endpoint exige sessão).
  minhas: Peca[] | null = null;

  constructor(private closetService: ClosetService, private authService: AuthService) {}

  ngOnInit(): void {
    this.carregar();
  }

  carregar(): void {
    this.carregando = true;
    this.erro = false;

    const minhas$ = this.authService.estaLogado()
      ? this.closetService.listarMinhas().pipe(catchError(() => of(null)))
      : of(null);

    forkJoin([
      this.closetService.listarDisponiveis().pipe(catchError(() => of(null))),
      minhas$,
    ]).subscribe(([disponiveis, minhas]) => {
      if (disponiveis === null) {
        this.erro = true;
        this.carregando = false;
        return;
      }
      this.disponiveis = disponiveis;
      this.minhas = minhas;
      this.carregando = false;
    });
  }

  get totalDisponiveis(): number {
    return this.disponiveis.length;
  }

  get valorEmCirculacao(): number {
    return this.disponiveis.reduce((soma, p) => soma + (p.preco ?? 0), 0);
  }

  get categorias(): CategoriaResumo[] {
    const contagem = new Map<string, number>();
    for (const peca of this.disponiveis) {
      contagem.set(peca.categoria, (contagem.get(peca.categoria) ?? 0) + 1);
    }
    return [...contagem.entries()]
      .map(([nome, quantidade]) => ({ nome, quantidade }))
      .sort((a, b) => b.quantidade - a.quantidade);
  }

  get maiorCategoria(): CategoriaResumo | null {
    return this.categorias[0] ?? null;
  }

  get minhasTotal(): number {
    return this.minhas?.length ?? 0;
  }

  get minhasVendidas(): number {
    return this.minhas?.filter((p) => p.status === 'sold').length ?? 0;
  }

  get minhasDisponiveis(): number {
    return this.minhas?.filter((p) => p.status !== 'sold').length ?? 0;
  }
}

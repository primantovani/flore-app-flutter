import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ClosetService } from '../../services/closet';
import { Peca } from '../../models/peca.model';

@Component({
  selector: 'app-admin',
  imports: [CommonModule, FormsModule],
  templateUrl: './admin.html',
  styleUrl: './admin.css'
})
export class Admin implements OnInit {
  pecas: Peca[] = [];
  carregando = true;
  erro = '';

  novaPeca: Peca = { nome: '', categoria: '', tamanho: '', preco: 0 };

  constructor(private closetService: ClosetService) {}

  ngOnInit(): void {
    this.buscarPecas();
  }

  buscarPecas(): void {
    this.carregando = true;
    this.erro = '';
    this.closetService.listarPecas().subscribe({
      next: (dados) => {
        this.pecas = dados;
        this.carregando = false;
      },
      error: () => {
        this.erro = 'Não foi possível carregar as peças. O backend ainda pode não estar disponível.';
        this.carregando = false;
      }
    });
  }

  cadastrarPeca(): void {
    if (!this.novaPeca.nome || !this.novaPeca.categoria) return;

    this.closetService.criarPeca(this.novaPeca).subscribe({
      next: (peca) => {
        this.pecas.push(peca);
        this.novaPeca = { nome: '', categoria: '', tamanho: '', preco: 0 };
      },
      error: () => {
        this.erro = 'Não foi possível cadastrar a peça agora.';
      }
    });
  }

  removerPeca(id: string | undefined): void {
    if (!id) return;
    this.closetService.removerPeca(id).subscribe({
      next: () => {
        this.pecas = this.pecas.filter(p => p.id !== id);
      },
      error: () => {
        this.erro = 'Não foi possível remover a peça agora.';
      }
    });
  }
}

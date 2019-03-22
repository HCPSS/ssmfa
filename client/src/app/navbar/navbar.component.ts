import { Component, OnInit } from '@angular/core';
import { environment } from '../../environments/environment'

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.scss']
})
export class NavbarComponent implements OnInit {
  logoUrl: string
  logoutUrl: string

  constructor() { }

  ngOnInit() {
    this.logoUrl = environment.logoUrl
    this.logoutUrl = environment.logoutUrl
  }

  signOut() {
    localStorage.clear()
    window.location.href = this.logoutUrl
  }
}

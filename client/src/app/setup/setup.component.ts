import { Component, OnInit } from '@angular/core'
import { AppComponent } from '../app.component'
import { Router } from '@angular/router'
import { environment } from '../../environments/environment'
import { Subject } from 'rxjs'
import { ApiService } from '../api.service'
import {
  debounceTime
} from 'rxjs/operators'

@Component({
  selector: 'app-setup',
  templateUrl: './setup.component.html',
  styleUrls: ['./setup.component.scss']
})
export class SetupComponent implements OnInit {
  start: boolean
  requestedAddress: string
  addressValid: boolean
  addressVerificationSent: boolean
  lastAddressVerificationSent: string
  addressChanges = new Subject<string>()
  invalidReason: string
  supportUrl: string

  constructor(
    private appComponent: AppComponent,
    private apiService: ApiService,
    private router: Router
  ) { }

  ngOnInit() {
    // make sure we have status
    if(!this.appComponent.status){
      this.router.navigateByUrl('/')
    }else{
      this.start = false
      this.addressValid = false
      this.requestedAddress = ''
      this.invalidReason = ''
      this.supportUrl = environment.supportUrl
      // subscribe to addressChanges
      this.addressChanges.pipe(
        debounceTime(500),
      ).subscribe(address => {
        this.validateAndSetAddress(address)
      })
    }
  }

  changeStart(){
    this.start = true
  }

  validateAndSetAddress(address: string){
    // check it's actually an email address
    const re = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
    if(re.test(address)){
      // check if email domain is not permitted
      let domainForbidden = false
      const domain = address.split('@')[1]
      const excludedDomains = environment.excludedDomains.split(',')
      for(let i=0; i < excludedDomains.length; i++){
        const pattern = new RegExp(excludedDomains[i].replace('.', '\\.') + '$')
        if(domainForbidden || pattern.test(domain.toLowerCase())){
          domainForbidden = true
        }
      }
      if(!domainForbidden){
        this.addressValid = true
        this.requestedAddress = address
        this.invalidReason = ''
      }else{
        this.addressValid = false
        this.requestedAddress = ''
        this.invalidReason = 'You may not use this domain'
      }
    }else{
      this.addressValid = false
      this.requestedAddress = ''
      this.invalidReason = 'This address is not formatted correctly'
    }
  }

  // push an address into the observable stream
  handleAddressChange(address: string){
    this.addressValid = false
    this.addressChanges.next(address)
  }

  submitAddress(address: string){
    this.apiService.postRequestRecoveryEmail(address)
      .subscribe(response => {
        if(response && response.success){
          this.lastAddressVerificationSent = address
          this.addressVerificationSent = true
        }else{
          console.log("failed to postRequestRecoveryEmail")
        }
      })
  }

}

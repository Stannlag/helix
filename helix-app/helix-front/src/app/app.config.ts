import { ApplicationConfig, provideZoneChangeDetection, importProvidersFrom } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { provideClientHydration, withEventReplay } from '@angular/platform-browser';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { initializeApp, provideFirebaseApp } from '@angular/fire/app';
import { getAuth, provideAuth } from '@angular/fire/auth';
import { environment } from '../environments/environment'; // Ensure this path is correct
import { provideHttpClient, withFetch } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    //provideClientHydration(withEventReplay()),
    provideRouter(routes),
    provideClientHydration(),
    provideAnimationsAsync(),
    // importProvidersFrom(provideFirebaseApp(() => initializeApp(environment.firebase))),
    // importProvidersFrom(provideAuth(() => getAuth())),
    provideFirebaseApp(() => initializeApp(environment.firebase)),
    provideAuth(() => getAuth()),
    provideHttpClient(withFetch()) // Added for API calls
  ]
};


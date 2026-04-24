# Internationalization (i18n)

Patterns for building multilingual React and Next.js applications with next-intl, react-intl, locale routing, RTL support, and pluralization.

## Next.js with next-intl

### Setup and Configuration

```typescript
// i18n/config.ts
export const locales = ['en', 'es', 'fr', 'ar', 'ja'] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = 'en';

export const rtlLocales: Locale[] = ['ar'];
export function isRTL(locale: Locale): boolean {
  return rtlLocales.includes(locale);
}

// i18n/request.ts
import { getRequestConfig } from 'next-intl/server';
import { locales, type Locale } from './config';

export default getRequestConfig(async ({ locale }) => {
  const validLocale = locales.includes(locale as Locale) ? locale : 'en';

  return {
    messages: (
      await import(`../messages/${validLocale}.json`)
    ).default,
  };
});
```

### App Router Integration

```typescript
// app/[locale]/layout.tsx
import { NextIntlClientProvider } from 'next-intl';
import { getMessages, getTranslations } from 'next-intl/server';
import { notFound } from 'next/navigation';
import { locales, isRTL, type Locale } from '@/i18n/config';

interface LocaleLayoutProps {
  children: React.ReactNode;
  params: { locale: string };
}

export function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

export async function generateMetadata({ params }: LocaleLayoutProps) {
  const t = await getTranslations({ locale: params.locale, namespace: 'metadata' });
  return {
    title: t('title'),
    description: t('description'),
  };
}

export default async function LocaleLayout({ children, params }: LocaleLayoutProps) {
  const { locale } = params;

  if (!locales.includes(locale as Locale)) {
    notFound();
  }

  const messages = await getMessages();

  return (
    <html lang={locale} dir={isRTL(locale as Locale) ? 'rtl' : 'ltr'}>
      <body>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

### Middleware for Locale Routing

```typescript
// middleware.ts
import createMiddleware from 'next-intl/middleware';
import { locales, defaultLocale } from './i18n/config';

export default createMiddleware({
  locales,
  defaultLocale,
  localePrefix: 'as-needed', // no prefix for default locale
  localeDetection: true,
});

export const config = {
  matcher: ['/', '/(en|es|fr|ar|ja)/:path*'],
};
```

## Message Files Structure

```jsonc
// messages/en.json
{
  "metadata": {
    "title": "My Application",
    "description": "A multilingual web application"
  },
  "common": {
    "loading": "Loading...",
    "error": "Something went wrong",
    "retry": "Try again",
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "confirm": "Are you sure?"
  },
  "nav": {
    "home": "Home",
    "about": "About",
    "contact": "Contact"
  },
  "auth": {
    "signIn": "Sign in",
    "signOut": "Sign out",
    "welcome": "Welcome, {name}!"
  },
  "products": {
    "count": "{count, plural, =0 {No products} one {# product} other {# products}}",
    "price": "Price: {amount, number, ::currency/USD}",
    "addedDate": "Added on {date, date, medium}"
  }
}
```

## Using Translations in Components

```typescript
// components/product-list.tsx
'use client';

import { useTranslations, useFormatter } from 'next-intl';

interface Product {
  id: string;
  name: string;
  price: number;
  addedAt: Date;
}

export function ProductList({ products }: { products: Product[] }) {
  const t = useTranslations('products');
  const format = useFormatter();

  return (
    <section>
      <h2>{t('count', { count: products.length })}</h2>
      <ul>
        {products.map((product) => (
          <li key={product.id}>
            <span>{product.name}</span>
            <span>
              {format.number(product.price, {
                style: 'currency',
                currency: 'USD',
              })}
            </span>
            <time>{format.dateTime(product.addedAt, { dateStyle: 'medium' })}</time>
          </li>
        ))}
      </ul>
    </section>
  );
}

// Server component usage
import { getTranslations } from 'next-intl/server';

export default async function ProductPage() {
  const t = await getTranslations('products');
  // Use t() the same way in server components
}
```

## React SPA with react-intl

```typescript
// i18n/provider.tsx
import { IntlProvider } from 'react-intl';
import { useState, useEffect, createContext, useContext } from 'react';

type Locale = 'en' | 'es' | 'fr' | 'ar';

interface I18nContextType {
  locale: Locale;
  setLocale: (locale: Locale) => void;
}

const I18nContext = createContext<I18nContextType>(null!);

export function I18nProvider({ children }: { children: React.ReactNode }) {
  const [locale, setLocale] = useState<Locale>(
    () => (navigator.language.split('-')[0] as Locale) || 'en'
  );
  const [messages, setMessages] = useState<Record<string, string>>({});

  useEffect(() => {
    import(`../messages/${locale}.json`)
      .then((mod) => setMessages(mod.default))
      .catch(() => import('../messages/en.json').then((mod) => setMessages(mod.default)));

    document.documentElement.lang = locale;
    document.documentElement.dir = ['ar'].includes(locale) ? 'rtl' : 'ltr';
  }, [locale]);

  return (
    <I18nContext.Provider value={{ locale, setLocale }}>
      <IntlProvider locale={locale} messages={messages} defaultLocale="en">
        {children}
      </IntlProvider>
    </I18nContext.Provider>
  );
}

export const useI18n = () => useContext(I18nContext);
```

## Locale Switcher Component

```typescript
// components/locale-switcher.tsx
'use client';

import { useLocale } from 'next-intl';
import { useRouter, usePathname } from 'next-intl/client';
import { locales, type Locale } from '@/i18n/config';

const localeNames: Record<Locale, string> = {
  en: 'English',
  es: 'Español',
  fr: 'Français',
  ar: 'العربية',
  ja: '日本語',
};

export function LocaleSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  function onLocaleChange(newLocale: string) {
    router.replace(pathname, { locale: newLocale });
  }

  return (
    <select
      value={locale}
      onChange={(e) => onLocaleChange(e.target.value)}
      aria-label="Select language"
    >
      {locales.map((loc) => (
        <option key={loc} value={loc}>
          {localeNames[loc]}
        </option>
      ))}
    </select>
  );
}
```

## RTL Support with Tailwind

```css
/* Global RTL-aware utilities */
/* Tailwind v3.3+ has built-in RTL support via rtl: and ltr: variants */

/* Example usage in components:
   <div className="ml-4 rtl:mr-4 rtl:ml-0">
   <div className="text-left rtl:text-right">
   <div className="pl-6 rtl:pr-6 rtl:pl-0">
*/
```

```typescript
// Use logical properties for automatic RTL
// Instead of margin-left/right, use margin-inline-start/end
export function RTLAwareCard({ children }: { children: React.ReactNode }) {
  return (
    <div
      style={{
        marginInlineStart: '1rem',
        paddingInlineEnd: '1.5rem',
        borderInlineStart: '3px solid var(--accent)',
        textAlign: 'start', // instead of 'left'
      }}
    >
      {children}
    </div>
  );
}
```

## Pluralization and ICU Message Format

```jsonc
{
  "notifications": {
    // Basic plural
    "count": "{count, plural, =0 {No notifications} one {# notification} other {# notifications}}",

    // Select (gender-aware)
    "greeting": "{gender, select, male {He} female {She} other {They}} liked your post",

    // Nested: plural inside select
    "activity": "{gender, select, male {He has} female {She has} other {They have}} {count, plural, one {# new message} other {# new messages}}",

    // Ordinal
    "ranking": "You finished in {place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}} place"
  }
}
```

## Checklist

- [ ] All user-visible strings extracted to message files (no hardcoded text)
- [ ] Pluralization uses ICU MessageFormat, not ternary operators
- [ ] Dates, numbers, and currencies formatted with `Intl` or library formatters
- [ ] RTL support via CSS logical properties or `rtl:` Tailwind variants
- [ ] `lang` and `dir` attributes set on `<html>` element
- [ ] Locale switcher is accessible (labeled select or radio group)
- [ ] Message files organized by feature namespace
- [ ] Fallback locale configured for missing translations
- [ ] Dynamic imports for message files (code-split per locale)
- [ ] SEO: `hreflang` tags and locale-prefixed URLs
- [ ] Form validation messages are translated
- [ ] Images with text have locale-specific alternatives or overlays

## Anti-Patterns

- String concatenation for translated sentences (`t('hello') + name` breaks word order)
- Using array indices as translation keys (`messages[0]`)
- Hardcoding date/number formats instead of using `Intl` APIs
- Assuming text length — German is ~30% longer than English, plan layout accordingly
- Missing `key` prop when locale changes (forces remount for format updates)
- Translating enum values inline instead of mapping to message keys
- Not testing with RTL languages during development

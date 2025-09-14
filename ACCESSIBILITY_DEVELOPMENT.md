# دليل التطوير المتقدم للوصولية - BookDoc

## ♿ نظرة عامة

يتبع مشروع BookDoc معايير الوصولية العالمية (WCAG 2.1 AA) لضمان إمكانية الوصول لجميع المستخدمين، بما في ذلك ذوي الاحتياجات الخاصة.

## 🎯 معايير الوصولية

### WCAG 2.1 AA Compliance
- **Perceivable**: المعلومات يجب أن تكون قابلة للإدراك
- **Operable**: واجهة المستخدم يجب أن تكون قابلة للتشغيل
- **Understandable**: المعلومات وواجهة المستخدم يجب أن تكون مفهومة
- **Robust**: المحتوى يجب أن يكون قوياً بما يكفي للعمل مع التقنيات المساعدة

## 🧩 مكونات الوصولية

### Accessible Button Component
```typescript
// src/components/accessible/AccessibleButton.tsx
import React, { forwardRef } from 'react';
import { ButtonHTMLAttributes } from 'react';

interface AccessibleButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'small' | 'medium' | 'large';
  loading?: boolean;
  children: React.ReactNode;
}

const AccessibleButton = forwardRef<HTMLButtonElement, AccessibleButtonProps>(
  ({ variant = 'primary', size = 'medium', loading = false, children, ...props }, ref) => {
    const baseClasses = 'inline-flex items-center justify-center font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors duration-200';
    
    const variantClasses = {
      primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
      secondary: 'bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500',
      outline: 'border border-blue-600 text-blue-600 hover:bg-blue-50 focus:ring-blue-500'
    };
    
    const sizeClasses = {
      small: 'px-3 py-2 text-sm',
      medium: 'px-4 py-2 text-base',
      large: 'px-6 py-3 text-lg'
    };

    return (
      <button
        ref={ref}
        className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${
          loading ? 'opacity-50 cursor-not-allowed' : ''
        }`}
        disabled={loading || props.disabled}
        aria-disabled={loading || props.disabled}
        aria-busy={loading}
        {...props}
      >
        {loading && (
          <svg
            className="animate-spin -ml-1 mr-2 h-4 w-4"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            />
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            />
          </svg>
        )}
        {children}
      </button>
    );
  }
);

AccessibleButton.displayName = 'AccessibleButton';

export default AccessibleButton;
```

### Accessible Form Component
```typescript
// src/components/accessible/AccessibleForm.tsx
import React, { useState } from 'react';
import { FieldError, UseFormRegister } from 'react-hook-form';

interface AccessibleFormFieldProps {
  label: string;
  name: string;
  type?: 'text' | 'email' | 'password' | 'tel' | 'url';
  required?: boolean;
  error?: FieldError;
  register: UseFormRegister<any>;
  placeholder?: string;
  description?: string;
  autoComplete?: string;
}

const AccessibleFormField: React.FC<AccessibleFormFieldProps> = ({
  label,
  name,
  type = 'text',
  required = false,
  error,
  register,
  placeholder,
  description,
  autoComplete
}) => {
  const [isFocused, setIsFocused] = useState(false);
  const fieldId = `field-${name}`;
  const errorId = `error-${name}`;
  const descriptionId = `description-${name}`;

  return (
    <div className="mb-4">
      <label
        htmlFor={fieldId}
        className="block text-sm font-medium text-gray-700 mb-2"
      >
        {label}
        {required && (
          <span className="text-red-500 ml-1" aria-label="مطلوب">
            *
          </span>
        )}
      </label>
      
      {description && (
        <p id={descriptionId} className="text-sm text-gray-600 mb-2">
          {description}
        </p>
      )}
      
      <input
        id={fieldId}
        type={type}
        {...register(name, { required: required ? `${label} مطلوب` : false })}
        placeholder={placeholder}
        autoComplete={autoComplete}
        aria-describedby={`${description ? descriptionId : ''} ${error ? errorId : ''}`.trim()}
        aria-invalid={error ? 'true' : 'false'}
        aria-required={required}
        className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
          error ? 'border-red-500' : 'border-gray-300'
        }`}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
      />
      
      {error && (
        <p
          id={errorId}
          className="mt-1 text-sm text-red-600"
          role="alert"
          aria-live="polite"
        >
          {error.message}
        </p>
      )}
    </div>
  );
};

export default AccessibleFormField;
```

### Accessible Modal Component
```typescript
// src/components/accessible/AccessibleModal.tsx
import React, { useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';

interface AccessibleModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  className?: string;
}

const AccessibleModal: React.FC<AccessibleModalProps> = ({
  isOpen,
  onClose,
  title,
  children,
  className = ''
}) => {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousActiveElement = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) {
      // Store the currently focused element
      previousActiveElement.current = document.activeElement as HTMLElement;
      
      // Focus the modal
      if (modalRef.current) {
        modalRef.current.focus();
      }
      
      // Prevent body scroll
      document.body.style.overflow = 'hidden';
      
      // Handle escape key
      const handleEscape = (e: KeyboardEvent) => {
        if (e.key === 'Escape') {
          onClose();
        }
      };
      
      document.addEventListener('keydown', handleEscape);
      
      return () => {
        document.removeEventListener('keydown', handleEscape);
        document.body.style.overflow = 'unset';
        
        // Restore focus
        if (previousActiveElement.current) {
          previousActiveElement.current.focus();
        }
      };
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return createPortal(
    <div
      className="fixed inset-0 z-50 overflow-y-auto"
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
        onClick={onClose}
        aria-hidden="true"
      />
      
      {/* Modal */}
      <div className="flex min-h-full items-center justify-center p-4">
        <div
          ref={modalRef}
          className={`relative bg-white rounded-lg shadow-xl max-w-md w-full ${className}`}
          tabIndex={-1}
        >
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b border-gray-200">
            <h2
              id="modal-title"
              className="text-lg font-semibold text-gray-900"
            >
              {title}
            </h2>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded-md p-1"
              aria-label="إغلاق النافذة"
            >
              <svg
                className="w-6 h-6"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
          
          {/* Content */}
          <div className="p-6">
            {children}
          </div>
        </div>
      </div>
    </div>,
    document.body
  );
};

export default AccessibleModal;
```

### Accessible Table Component
```typescript
// src/components/accessible/AccessibleTable.tsx
import React from 'react';

interface AccessibleTableProps {
  caption: string;
  headers: string[];
  data: any[][];
  className?: string;
}

const AccessibleTable: React.FC<AccessibleTableProps> = ({
  caption,
  headers,
  data,
  className = ''
}) => {
  return (
    <div className="overflow-x-auto">
      <table
        className={`min-w-full divide-y divide-gray-200 ${className}`}
        role="table"
        aria-label={caption}
      >
        <caption className="sr-only">
          {caption}
        </caption>
        
        <thead className="bg-gray-50">
          <tr role="row">
            {headers.map((header, index) => (
              <th
                key={index}
                scope="col"
                className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider"
                role="columnheader"
              >
                {header}
              </th>
            ))}
          </tr>
        </thead>
        
        <tbody className="bg-white divide-y divide-gray-200">
          {data.map((row, rowIndex) => (
            <tr key={rowIndex} role="row">
              {row.map((cell, cellIndex) => (
                <td
                  key={cellIndex}
                  className="px-6 py-4 whitespace-nowrap text-sm text-gray-900"
                  role="cell"
                >
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default AccessibleTable;
```

## 🎨 تصميم الوصولية

### Color Contrast
```css
/* src/styles/accessibility.css */

/* High contrast colors for better readability */
:root {
  --color-text-primary: #1a1a1a;
  --color-text-secondary: #4a4a4a;
  --color-background: #ffffff;
  --color-background-secondary: #f8f9fa;
  --color-border: #d1d5db;
  --color-focus: #2563eb;
  --color-error: #dc2626;
  --color-success: #059669;
  --color-warning: #d97706;
}

/* Focus indicators */
.focus-visible {
  outline: 2px solid var(--color-focus);
  outline-offset: 2px;
}

/* High contrast mode support */
@media (prefers-contrast: high) {
  :root {
    --color-text-primary: #000000;
    --color-text-secondary: #333333;
    --color-background: #ffffff;
    --color-border: #000000;
  }
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  :root {
    --color-text-primary: #f8f9fa;
    --color-text-secondary: #dee2e6;
    --color-background: #212529;
    --color-background-secondary: #343a40;
    --color-border: #495057;
  }
}
```

### Typography for Accessibility
```css
/* src/styles/typography.css */

/* Base font settings */
body {
  font-family: 'Cairo', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  font-size: 16px;
  line-height: 1.6;
  color: var(--color-text-primary);
  background-color: var(--color-background);
}

/* Heading hierarchy */
h1 {
  font-size: 2.25rem;
  font-weight: 700;
  line-height: 1.2;
  margin-bottom: 1rem;
}

h2 {
  font-size: 1.875rem;
  font-weight: 600;
  line-height: 1.3;
  margin-bottom: 0.875rem;
}

h3 {
  font-size: 1.5rem;
  font-weight: 600;
  line-height: 1.4;
  margin-bottom: 0.75rem;
}

h4 {
  font-size: 1.25rem;
  font-weight: 500;
  line-height: 1.4;
  margin-bottom: 0.625rem;
}

h5 {
  font-size: 1.125rem;
  font-weight: 500;
  line-height: 1.5;
  margin-bottom: 0.5rem;
}

h6 {
  font-size: 1rem;
  font-weight: 500;
  line-height: 1.5;
  margin-bottom: 0.5rem;
}

/* Text sizes for different contexts */
.text-xs { font-size: 0.75rem; }
.text-sm { font-size: 0.875rem; }
.text-base { font-size: 1rem; }
.text-lg { font-size: 1.125rem; }
.text-xl { font-size: 1.25rem; }
.text-2xl { font-size: 1.5rem; }
.text-3xl { font-size: 1.875rem; }
.text-4xl { font-size: 2.25rem; }

/* Line heights for readability */
.leading-tight { line-height: 1.25; }
.leading-snug { line-height: 1.375; }
.leading-normal { line-height: 1.5; }
.leading-relaxed { line-height: 1.625; }
.leading-loose { line-height: 2; }
```

## 🔧 أدوات الوصولية

### Accessibility Testing
```typescript
// src/utils/accessibility.ts
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

export const accessibilityTest = async (container: HTMLElement) => {
  const results = await axe(container);
  expect(results).toHaveNoViolations();
};

// Keyboard navigation helper
export const simulateKeyboardNavigation = (element: HTMLElement, key: string) => {
  const event = new KeyboardEvent('keydown', {
    key,
    code: key,
    bubbles: true,
    cancelable: true
  });
  
  element.dispatchEvent(event);
};

// Screen reader text helper
export const getScreenReaderText = (element: HTMLElement): string => {
  const ariaLabel = element.getAttribute('aria-label');
  const ariaLabelledBy = element.getAttribute('aria-labelledby');
  const textContent = element.textContent;
  
  if (ariaLabel) return ariaLabel;
  if (ariaLabelledBy) {
    const labelElement = document.getElementById(ariaLabelledBy);
    return labelElement?.textContent || '';
  }
  return textContent || '';
};

// Focus management
export const trapFocus = (container: HTMLElement) => {
  const focusableElements = container.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  
  const firstElement = focusableElements[0] as HTMLElement;
  const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement;
  
  const handleTabKey = (e: KeyboardEvent) => {
    if (e.key === 'Tab') {
      if (e.shiftKey) {
        if (document.activeElement === firstElement) {
          lastElement.focus();
          e.preventDefault();
        }
      } else {
        if (document.activeElement === lastElement) {
          firstElement.focus();
          e.preventDefault();
        }
      }
    }
  };
  
  container.addEventListener('keydown', handleTabKey);
  
  return () => {
    container.removeEventListener('keydown', handleTabKey);
  };
};
```

### Screen Reader Support
```typescript
// src/hooks/useScreenReader.ts
import { useState, useEffect } from 'react';

export const useScreenReader = () => {
  const [isScreenReaderActive, setIsScreenReaderActive] = useState(false);

  useEffect(() => {
    // Check if screen reader is active
    const checkScreenReader = () => {
      const hasScreenReader = window.speechSynthesis || window.speechSynthesis?.speak;
      setIsScreenReaderActive(!!hasScreenReader);
    };

    checkScreenReader();
    
    // Listen for screen reader events
    const handleScreenReaderChange = () => {
      checkScreenReader();
    };

    window.addEventListener('focus', handleScreenReaderChange);
    window.addEventListener('blur', handleScreenReaderChange);

    return () => {
      window.removeEventListener('focus', handleScreenReaderChange);
      window.removeEventListener('blur', handleScreenReaderChange);
    };
  }, []);

  return { isScreenReaderActive };
};

// Announce messages to screen readers
export const announceToScreenReader = (message: string) => {
  const announcement = document.createElement('div');
  announcement.setAttribute('aria-live', 'polite');
  announcement.setAttribute('aria-atomic', 'true');
  announcement.className = 'sr-only';
  announcement.textContent = message;
  
  document.body.appendChild(announcement);
  
  setTimeout(() => {
    document.body.removeChild(announcement);
  }, 1000);
};
```

## 🧪 اختبارات الوصولية

### Accessibility Test Suite
```typescript
// src/__tests__/accessibility.test.tsx
import React from 'react';
import { render, screen } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import AccessibleButton from '../components/accessible/AccessibleButton';
import AccessibleForm from '../components/accessible/AccessibleForm';
import AccessibleModal from '../components/accessible/AccessibleModal';

expect.extend(toHaveNoViolations);

describe('Accessibility Tests', () => {
  test('AccessibleButton has no accessibility violations', async () => {
    const { container } = render(
      <AccessibleButton onClick={() => {}}>
        Click me
      </AccessibleButton>
    );
    
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  test('AccessibleForm has no accessibility violations', async () => {
    const { container } = render(
      <AccessibleForm
        fields={[
          {
            name: 'email',
            label: 'البريد الإلكتروني',
            type: 'email',
            required: true
          }
        ]}
        onSubmit={() => {}}
      />
    );
    
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  test('AccessibleModal has no accessibility violations', async () => {
    const { container } = render(
      <AccessibleModal
        isOpen={true}
        onClose={() => {}}
        title="Test Modal"
      >
        <p>Modal content</p>
      </AccessibleModal>
    );
    
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  test('Button has proper ARIA attributes', () => {
    render(
      <AccessibleButton
        loading={true}
        disabled={false}
        onClick={() => {}}
      >
        Loading...
      </AccessibleButton>
    );
    
    const button = screen.getByRole('button');
    expect(button).toHaveAttribute('aria-busy', 'true');
    expect(button).toHaveAttribute('aria-disabled', 'false');
  });

  test('Form field has proper labels and descriptions', () => {
    render(
      <AccessibleForm
        fields={[
          {
            name: 'password',
            label: 'كلمة المرور',
            type: 'password',
            required: true,
            description: 'يجب أن تكون 8 أحرف على الأقل'
          }
        ]}
        onSubmit={() => {}}
      />
    );
    
    const passwordField = screen.getByLabelText(/كلمة المرور/i);
    expect(passwordField).toHaveAttribute('aria-required', 'true');
    expect(passwordField).toHaveAttribute('aria-describedby');
  });
});
```

## 📱 الوصولية المحمولة

### Touch Accessibility
```typescript
// src/components/accessible/TouchableArea.tsx
import React from 'react';

interface TouchableAreaProps {
  children: React.ReactNode;
  onClick: () => void;
  className?: string;
  disabled?: boolean;
}

const TouchableArea: React.FC<TouchableAreaProps> = ({
  children,
  onClick,
  className = '',
  disabled = false
}) => {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`min-h-[44px] min-w-[44px] touch-manipulation ${className}`}
      style={{
        // Ensure minimum touch target size
        minHeight: '44px',
        minWidth: '44px',
        // Improve touch response
        touchAction: 'manipulation'
      }}
    >
      {children}
    </button>
  );
};

export default TouchableArea;
```

### Responsive Accessibility
```typescript
// src/hooks/useResponsiveAccessibility.ts
import { useState, useEffect } from 'react';

export const useResponsiveAccessibility = () => {
  const [isMobile, setIsMobile] = useState(false);
  const [isTablet, setIsTablet] = useState(false);
  const [isDesktop, setIsDesktop] = useState(false);

  useEffect(() => {
    const checkScreenSize = () => {
      const width = window.innerWidth;
      setIsMobile(width < 768);
      setIsTablet(width >= 768 && width < 1024);
      setIsDesktop(width >= 1024);
    };

    checkScreenSize();
    window.addEventListener('resize', checkScreenSize);

    return () => {
      window.removeEventListener('resize', checkScreenSize);
    };
  }, []);

  return { isMobile, isTablet, isDesktop };
};
```

## 📞 الدعم

للمساعدة في التطوير المتقدم للوصولية:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [React Accessibility](https://reactjs.org/docs/accessibility.html)
- [Jest Axe](https://github.com/nickcolley/jest-axe)
- [WebAIM](https://webaim.org/)
- [A11y Project](https://www.a11yproject.com/)

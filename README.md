# Tokenized Subscription Management System

This project implements a tokenized subscription management system using Clarity smart contracts for the Stacks blockchain. The system enables service providers to offer subscription-based services with automated billing and usage tracking.

## System Components

The system consists of five main contracts:

1. **Provider Verification Contract**: Validates legitimate service companies
2. **Subscriber Identity Contract**: Manages customer profiles
3. **Service Level Contract**: Records agreed terms and features
4. **Usage Tracking Contract**: Monitors consumption of services
5. **Billing Contract**: Handles automated payment processing

## Contract Details

### Provider Verification Contract

This contract maintains a registry of verified service providers. Key features:
- Register new providers
- Verify providers (admin only)
- Check provider verification status

### Subscriber Identity Contract

This contract manages subscriber profiles. Key features:
- Self-registration for subscribers
- Profile updates
- Account deactivation

### Service Level Contract

This contract defines service tiers and manages subscription agreements. Key features:
- Define service tiers with features and pricing
- Subscribe to services
- Cancel subscriptions
- Check subscription status

### Usage Tracking Contract

This contract tracks service usage. Key features:
- Record usage data
- Retrieve usage statistics
- Correct usage records (admin only)

### Billing Contract

This contract handles payment processing. Key features:
- Process payments
- Withdraw funds (for providers)
- Platform fee management

## Usage

### For Service Providers

1. Register in the Provider Verification Contract
2. Wait for admin verification
3. Define service tiers in the Service Level Contract
4. Record usage in the Usage Tracking Contract
5. Withdraw funds from the Billing Contract

### For Subscribers

1. Register in the Subscriber Identity Contract
2. Subscribe to services in the Service Level Contract
3. Make payments through the Billing Contract

## Testing

Tests are written using Vitest and can be found in the `tests` directory.

## Future Improvements

- Implement token-based payments
- Add dispute resolution mechanisms
- Enhance subscription renewal logic
- Implement tiered pricing based on usage
  \`\`\`

```js file="tests/provider-verification.test.js" type="nodejs"
import { describe, it, expect, beforeEach } from 'vitest';

// Mock implementation for testing Clarity contracts
// In a real environment, you would use a Clarity testing framework

const mockState = {
  admin: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  verifiedProviders: new Map()
};

// Mock functions to simulate contract behavior
function registerProvider(caller, providerPrincipal, providerName) {
  if (caller !== mockState.admin) {
    return { type: 'err', value: 1 };
  }
  
  mockState.verifiedProviders.set(providerPrincipal, {
    name: providerName,
    verified: false,
    verificationDate: 0
  });
  
  return { type: 'ok', value: true };
}

function verifyProvider(caller, providerPrincipal) {
  if (caller !== mockState.admin) {
    return { type: 'err', value: 1 };
  }
  
  if (!mockState.verifiedProviders.has(providerPrincipal)) {
    return { type: 'err', value: 2 };
  }
  
  const providerData = mockState.verifiedProviders.get(providerPrincipal);
  mockState.verifiedProviders.set(providerPrincipal, {
    ...providerData,
    verified: true,
    verificationDate: 123 // Mock block height
  });
  
  return { type: 'ok', value: true };
}

function isVerifiedProvider(providerPrincipal) {
  if (!mockState.verifiedProviders.has(providerPrincipal)) {
    return { type: 'err', value: 3 };
  }
  
  const providerData = mockState.verifiedProviders.get(providerPrincipal);
  return { type: 'ok', value: providerData.verified };
}

function getProviderDetails(providerPrincipal) {
  return mockState.verifiedProviders.get(providerPrincipal) || null;
}

function transferAdmin(caller, newAdmin) {
  if (caller !== mockState.admin) {
    return { type: 'err', value: 1 };
  }
  
  mockState.admin = newAdmin;
  return { type: 'ok', value: true };
}

// Tests
describe('Provider Verification Contract', () => {
  beforeEach(() => {
    // Reset state before each test
    mockState.admin = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    mockState.verifiedProviders = new Map();
  });

  it('should register a provider when called by admin', () => {
    const result = registerProvider(
      'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
      'Test Provider'
    );
    
    expect(result.type).toBe('ok');
    expect(mockState.verifiedProviders.has('ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG')).toBe(true);
    
    const providerData = mockState.verifiedProviders.get('ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG');
    expect(providerData.name).toBe('Test Provider');
    expect(providerData.verified).toBe(false);
  });

  it('should not register a provider when called by non-admin', () => {
    const result = registerProvider(
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
      'Test Provider'
    );
    
    expect(result.type).toBe('err');
    expect(result.value).toBe(1);
    expect(mockState.verifiedProviders.has('ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG')).toBe(false);
  });

  it('should verify a provider when called by admin', () => {
    // First register the provider
    registerProvider(
      'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
      'Test Provider'
    );
    
    // Then verify the provider
    const result = verifyProvider(
      'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG'
    );
    
    expect(result.type).toBe('ok');
    
    const providerData = mockState.verifiedProviders.get('ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG');
    expect(providerData.verified).toBe(true);
    expect(providerData.verificationDate).toBe(123);
  });

  it('should check if a provider is verified', () => {
    // Register and verify a provider
    registerProvider(
      'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
      'Test Provider'
    );
    
    verifyProvider(
      'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG'
    );
    
    // Check verification status
    const result = isVerifiedProvider('ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG');
    
    expect(result.type).toBe('ok');
    expect(result.value).toBe(true);
  });

  it('should transfer admin rights', () => {
    const newAdmin = 'ST3AM1A56AK2C1XAFJ4115ZSV26EB49BVQ10MGCS0';
    
    const result = transferAdmin(
      'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      newAdmin
    );
    
    expect(result.type).toBe('ok');
    expect(mockState.admin).toBe(newAdmin);
    
    // Verify that old admin can no longer perform admin actions
    const registerResult = registerProvider(
      'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
      'Test Provider'
    );
    
    expect(registerResult.type).toBe('err');
    
    // Verify that new admin can perform admin actions
    const newRegisterResult = registerProvider(
      newAdmin,
      'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
      'Test Provider'
    );
    
    expect(newRegisterResult.type).toBe('ok');
  });
});

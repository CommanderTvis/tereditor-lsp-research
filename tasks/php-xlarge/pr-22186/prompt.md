# Payment methods are not updated when customer type changes during checkout using rule builder

### Shopware Version

6.6.10.4

### Affected area / extension

Platform(Default)

### Actual behaviour

I have an rule builder for payment methods. Depending on wether the customer is of type company or private i provide different payment methods. It works for the initial checkout but as soon as the address type changes in checkout/confirm the payment methods are not updated or reloaded.

Same issue occurs with shipping methods.

### Expected behaviour

Payment methods are updated when the customer type is changed to private or company in checkout.

### How to reproduce

1. Create a rule builder for payment methods that are only shown for customer type 'company'
2. Assign the rule to a payment method that should only visible for customer type 'company'
3. Go to shop select a product and proceed to checkout as new customer
4. Fill all adddress fields as private customer
5. Proceed to payment page
6. Change address and customer type to 'company'
7. Payment mehtods are not updated according to rule builder

Hint: The payment/shipping methods are updated if i'm logged in with an account and change the account type in the settings. So the issue seems to related to guest users.

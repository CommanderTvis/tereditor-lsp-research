# Oracle: references of pydantic_extra_types.payment.PaymentCardNumber

Derived without a language server: an ast walk over every .py file of the repository (names, attribute accesses and
import aliases equal to `PaymentCardNumber`; strings and comments are not nodes), checked by hand against the word
search

    grep -rnw PaymentCardNumber . -I          # 24 lines at the pinned commit

Kept (14 locations): the import lines (tests/test_json_schema.py:22, tests/test_types_payment.py:8), the uses in
payment.py (:70 the return annotation of `validate`, :216 the call `PaymentCardNumber._identify_brand`) and in the tests
(annotation at test_types_payment.py:47, calls at :54, :56, :58, :94, :97, :133, :136, :162, the list entry
tests/test_json_schema.py:75).

Dropped: the class statement (payment.py:35); docstrings and cross-references (payment.py:2, :15, :71, :78);
tests/test_types_payment.py:39 (comment) and :40 (the string name given to `namedtuple`); HISTORY.md:268 (changelog).

Judgement calls: payment.py:70 is kept: a return annotation naming the class is a use in code.

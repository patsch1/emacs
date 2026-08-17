;;; my-packages-test.el --- Tests for package management -*- lexical-binding: t; -*-

(require 'ert)
(require 'my-packages)

(defun my/package-test-desc ()
  "Return a minimal VC package descriptor for tests."
  (package-desc-create
   :name 'example
   :version '(1 0)
   :summary "Test package"
   :reqs nil
   :kind 'vc
   :dir temporary-file-directory))

(ert-deftest my/package-direct-dependencies-are-not-removable ()
  (should-not
   (seq-intersection my/package-selected-packages
                     (package--removable-packages))))

(ert-deftest my/package-archive-order-prefers-official-sources ()
  (should (> (alist-get "gnu" my/package-archive-priorities nil nil #'equal)
             (alist-get "nongnu" my/package-archive-priorities nil nil #'equal)))
  (should (> (alist-get "nongnu" my/package-archive-priorities nil nil #'equal)
             (alist-get "melpa" my/package-archive-priorities nil nil #'equal))))

(ert-deftest my/package-vc-git-state-parses-revision-counts ()
  (let ((desc (my/package-test-desc)))
    (dolist (case '(("0 0" current)
                    ("0 3" update)
                    ("2 0" ahead)
                    ("2 3" error)
                    ("not-a-count" error)))
      (cl-letf (((symbol-function 'my/package-git-run)
                 (lambda (&rest _) (cons 0 (car case)))))
        (should (eq (plist-get (my/package-vc-git-state desc) :state)
                    (cadr case)))))))

(provide 'my-packages-test)
;;; my-packages-test.el ends here

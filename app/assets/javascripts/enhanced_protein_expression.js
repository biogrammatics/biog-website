// Enhanced Protein Expression Page JavaScript
document.addEventListener('DOMContentLoaded', function() {
  // Get DOM elements
  const inputMethodRadios = document.querySelectorAll('input[name="enhanced_protein_expression_form[input_method]"]');
  const fastaSection = document.getElementById('fasta-upload-section');
  const manualSection = document.getElementById('manual-entry-section');
  const addProteinBtn = document.getElementById('add-protein-btn');
  const proteinsContainer = document.getElementById('proteins-container');
  const customStrainCheckbox = document.getElementById('strain_selection');
  const customStrainInput = document.getElementById('custom-strain-input');

  let proteinCount = 0;

  // Get data from window object (set by the view)
  const secretionSignals = window.proteinFormData?.secretionSignals || [];
  const nTerminalTags = window.proteinFormData?.nTerminalTags || [];
  const cTerminalTags = window.proteinFormData?.cTerminalTags || [];

  // Debug logging
  console.log('Enhanced Protein Expression JS loaded');
  console.log('Data available:', {
    secretionSignals: secretionSignals.length,
    nTerminalTags: nTerminalTags.length,
    cTerminalTags: cTerminalTags.length
  });

  // Handle custom strain selection
  if (customStrainCheckbox) {
    customStrainCheckbox.addEventListener('change', function() {
      customStrainInput.style.display = this.checked ? 'block' : 'none';
    });
  }

  // Handle input method switching
  inputMethodRadios.forEach(radio => {
    radio.addEventListener('change', function() {
      if (this.value === 'fasta') {
        fastaSection.style.display = 'block';
        manualSection.style.display = 'none';
      } else {
        fastaSection.style.display = 'none';
        manualSection.style.display = 'block';
        if (proteinCount === 0) {
          addProteinForm();
        }
      }
    });
  });

  // Initialize with manual input (default)
  if (manualSection && fastaSection) {
    manualSection.style.display = 'block';
    fastaSection.style.display = 'none';
    addProteinForm();
  }

  // Add protein form
  if (addProteinBtn) {
    addProteinBtn.addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Add protein button clicked');
      addProteinForm();
    });
  }

  function addProteinForm() {
    console.log('Adding protein form #' + (proteinCount + 1));
    proteinCount++;
    const proteinForm = createProteinForm(proteinCount);
    if (proteinsContainer) {
      proteinsContainer.appendChild(proteinForm);
      updateRemoveButtons();
    }
  }

  function createProteinForm(number) {
    const div = document.createElement('div');
    div.className = 'protein-form card mb-3';

    // Build secretion signal options
    let secretionSignalOptions = '<option value="">None</option>';
    secretionSignals.forEach(signal => {
      secretionSignalOptions += `<option value="${escapeHtml(signal.value)}">${escapeHtml(signal.name)}</option>`;
    });

    // Build N-terminal tag options
    let nTerminalOptions = '<option value="">None</option>';
    nTerminalTags.forEach(tag => {
      nTerminalOptions += `<option value="${escapeHtml(tag.value)}">${escapeHtml(tag.name)}</option>`;
    });

    // Build C-terminal tag options
    let cTerminalOptions = '<option value="">None</option>';
    cTerminalTags.forEach(tag => {
      cTerminalOptions += `<option value="${escapeHtml(tag.value)}">${escapeHtml(tag.name)}</option>`;
    });

    div.innerHTML = `
      <div class="card-header d-flex justify-content-between align-items-center">
        <h6 class="mb-0">Protein ${number}</h6>
        <button type="button" class="btn btn-outline-danger btn-sm remove-protein-btn">
          <i class="fas fa-times"></i>
        </button>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <div class="mb-3">
              <label class="form-label">Protein Name</label>
              <input type="text" name="enhanced_protein_expression_form[proteins_attributes][${number-1}][name]"
                     class="form-control" placeholder="e.g., Human Insulin">
            </div>
          </div>
          <div class="col-md-6">
            <div class="mb-3">
              <label class="form-label">Description (Optional)</label>
              <input type="text" name="enhanced_protein_expression_form[proteins_attributes][${number-1}][description]"
                     class="form-control" placeholder="Brief description">
            </div>
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label">Amino Acid Sequence</label>
          <textarea name="enhanced_protein_expression_form[proteins_attributes][${number-1}][amino_acid_sequence]"
                    rows="4" class="form-control font-monospace sequence-input"
                    placeholder="MATLYGDSGLWQNILDQLSSLLNQAEGLQAAGGSALQY*"></textarea>
          <small class="form-text text-muted">Single-letter amino acid codes (A-Z, *)</small>
        </div>

        <div class="row">
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label">Secretion Signal</label>
              <select name="enhanced_protein_expression_form[proteins_attributes][${number-1}][secretion_signal]"
                      class="form-select">
                ${secretionSignalOptions}
              </select>
            </div>
          </div>
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label">N-Terminal Tag</label>
              <select name="enhanced_protein_expression_form[proteins_attributes][${number-1}][n_terminal_tag]"
                      class="form-select">
                ${nTerminalOptions}
              </select>
            </div>
          </div>
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label">C-Terminal Tag</label>
              <select name="enhanced_protein_expression_form[proteins_attributes][${number-1}][c_terminal_tag]"
                      class="form-select">
                ${cTerminalOptions}
              </select>
            </div>
          </div>
        </div>
      </div>
    `;

    // Add remove functionality
    const removeBtn = div.querySelector('.remove-protein-btn');
    removeBtn.addEventListener('click', function() {
      div.remove();
      proteinCount--;
      updateProteinNumbers();
      updateRemoveButtons();
    });

    // Add sequence formatting
    const sequenceInput = div.querySelector('.sequence-input');
    sequenceInput.addEventListener('input', function() {
      this.value = this.value.toUpperCase().replace(/[^ARNDCEQGHILKMFPSTWYV*\s]/g, '');
    });

    return div;
  }

  function updateProteinNumbers() {
    const forms = proteinsContainer.querySelectorAll('.protein-form');
    forms.forEach((form, index) => {
      const numberSpan = form.querySelector('.protein-number');
      if (numberSpan) {
        numberSpan.textContent = index + 1;
      }

      // Update input names
      const inputs = form.querySelectorAll('input, select, textarea');
      inputs.forEach(input => {
        if (input.name) {
          input.name = input.name.replace(/\[\d+\]/, `[${index}]`);
        }
      });
    });
  }

  function updateRemoveButtons() {
    const forms = proteinsContainer.querySelectorAll('.protein-form');
    const removeButtons = proteinsContainer.querySelectorAll('.remove-protein-btn');

    removeButtons.forEach(btn => {
      btn.style.display = forms.length > 1 ? 'block' : 'none';
    });
  }

  function escapeHtml(text) {
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
  }
});
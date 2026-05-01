import 'package:flutter/material.dart';

class JobFiltersPage extends StatefulWidget {
  const JobFiltersPage({super.key});

  @override
  State<JobFiltersPage> createState() => _JobFiltersPageState();
}

class _JobFiltersPageState extends State<JobFiltersPage> {
  // Expanded states
  bool _isCountryExpanded = false;
  bool _isDateExpanded = false;
  bool _isSportExpanded = false;
  bool _isTypeExpanded = false;

  // Selected values (using Sets for multiple selections)
  final Set<String> _selectedCountries = {};
  String? _selectedDate;
  final Set<String> _selectedSports = {};
  final Set<String> _selectedTypes = {};

  // Mock data lists
  final List<String> _countries = ['Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bangladesh', 'Bélgica', 'Bulgaria'];
  final List<String> _dates = ['Cualquier momento', 'Últimas 24 horas', 'Semana pasada', 'Mes pasado'];
  final List<String> _sports = ['Futbol', 'Baloncesto', 'Baseball', 'Natación', 'Boxeo', 'Karate', 'Remo', 'Polo'];
  final List<String> _types = ['Jornada completa', 'Media jornada', 'Temporal', 'Prácticas', 'Voluntariado', 'Por contrato', 'Freelancer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A43),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00183F),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text('Filtrar empleos por', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildFilterAccordion(
                  title: 'País',
                  isExpanded: _isCountryExpanded,
                  onToggle: () => setState(() => _isCountryExpanded = !_isCountryExpanded),
                  child: _buildCheckboxListWithSearch(_countries, _selectedCountries, 'Buscar país'),
                ),
                _buildDivider(),
                _buildFilterAccordion(
                  title: 'Fecha de publicación',
                  isExpanded: _isDateExpanded,
                  onToggle: () => setState(() => _isDateExpanded = !_isDateExpanded),
                  child: _buildRadioList(_dates, _selectedDate, (val) => setState(() => _selectedDate = val)),
                ),
                _buildDivider(),
                _buildFilterAccordion(
                  title: 'Deporte',
                  isExpanded: _isSportExpanded,
                  onToggle: () => setState(() => _isSportExpanded = !_isSportExpanded),
                  child: _buildCheckboxListWithSearch(_sports, _selectedSports, 'Buscar deporte'),
                ),
                _buildDivider(),
                _buildFilterAccordion(
                  title: 'Tipo de empleo',
                  isExpanded: _isTypeExpanded,
                  onToggle: () => setState(() => _isTypeExpanded = !_isTypeExpanded),
                  child: _buildCheckboxList(_types, _selectedTypes),
                ),
                _buildDivider(),
              ],
            ),
          ),
          
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF00183F),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCountries.clear();
                          _selectedDate = null;
                          _selectedSports.clear();
                          _selectedTypes.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Limpiar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply Filters
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withValues(alpha: 0.5), // Disabled looking state based on mockup if nothing is selected
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Aplicar filtros', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.white12);
  }

  Widget _buildFilterAccordion({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: child,
          ),
      ],
    );
  }

  Widget _buildSearchInput(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCheckboxList(List<String> items, Set<String> selectedItems) {
    return Column(
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return InkWell(
          onTap: () {
            setState(() {
              isSelected ? selectedItems.remove(item) : selectedItems.add(item);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.blueAccent : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(item, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxListWithSearch(List<String> items, Set<String> selectedItems, String hint) {
    return Column(
      children: [
        _buildSearchInput(hint),
        _buildCheckboxList(items, selectedItems),
      ],
    );
  }

  Widget _buildRadioList(List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    return Column(
      children: items.map((item) {
        final isSelected = selectedItem == item;
        return InkWell(
          onTap: () => onChanged(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blueAccent : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(item, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
